import SceneKit
import SwiftUI

/// The one custom surface: weave nodes along a rail. Lit node is the only hero.
struct WeaveRailView: UIViewRepresentable {
    var nodes: [WeaveNode]
    var litID: UUID?
    @Binding var litAnchor: CGPoint?

    func makeCoordinator() -> Coordinator {
        Coordinator(anchor: $litAnchor)
    }

    func makeUIView(context: Context) -> RailHost {
        let view = RailHost()
        view.backgroundColor = .clear
        view.scene = SCNScene()
        view.allowsCameraControl = false
        view.isAccessibilityElement = false
        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 1.6, 8)
        camera.look(at: SCNVector3(0, 0, 0))
        view.scene?.rootNode.addChildNode(camera)
        let light = SCNNode()
        light.light = SCNLight()
        light.light?.type = .omni
        light.position = SCNVector3(2, 4, 6)
        view.scene?.rootNode.addChildNode(light)
        view.onProject = { point in
            MainActor.assumeIsolated {
                context.coordinator.update(point)
            }
        }
        return view
    }

    func updateUIView(_ view: RailHost, context: Context) {
        guard let scene = view.scene else { return }
        scene.rootNode.childNodes.filter { $0.name == "node" || $0.name == "lit" }.forEach { $0.removeFromParentNode() }
        let count = nodes.count
        let markers: [(CGFloat, Bool)] = nodes.enumerated().map { index, node in
            let span = CGFloat(max(count - 1, 1))
            let x = count == 1 ? 0 : (CGFloat(index) / span) * 6 - 3
            return (x, node.id == litID)
        }
        var litMarker: SCNNode?
        for (x, lit) in markers {
            let sphere = SCNSphere(radius: lit ? 0.28 : 0.16)
            sphere.firstMaterial?.diffuse.contents = lit
                ? UIColor(DesignTokens.accent)
                : UIColor(DesignTokens.muted)
            let marker = SCNNode(geometry: sphere)
            marker.name = lit ? "lit" : "node"
            marker.position = SCNVector3(Float(x), lit ? 0.15 : 0, 0)
            scene.rootNode.addChildNode(marker)
            if lit { litMarker = marker }
        }
        if scene.rootNode.childNode(withName: "rail", recursively: false) == nil {
            let box = SCNBox(width: 6.4, height: 0.04, length: 0.08, chamferRadius: 0.02)
            box.firstMaterial?.diffuse.contents = UIColor(DesignTokens.ink).withAlphaComponent(0.35)
            let rail = SCNNode(geometry: box)
            rail.name = "rail"
            rail.position = SCNVector3(0, -0.2, 0)
            scene.rootNode.addChildNode(rail)
        }
        view.litNode = litMarker
        view.publish()
    }

    final class Coordinator {
        var anchor: Binding<CGPoint?>

        init(anchor: Binding<CGPoint?>) {
            self.anchor = anchor
        }

        @MainActor
        func update(_ point: CGPoint?) {
            let current = anchor.wrappedValue
            if let point, let current, hypot(point.x - current.x, point.y - current.y) < 1 {
                return
            }
            if point == nil, current == nil {
                return
            }
            anchor.wrappedValue = point
        }
    }
}

final class RailHost: SCNView {
    var litNode: SCNNode?
    var onProject: ((CGPoint?) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        publish()
    }

    func publish() {
        guard bounds.width > 1, let litNode else {
            onProject?(nil)
            return
        }
        let projected = projectPoint(litNode.position)
        let point = CGPoint(x: CGFloat(projected.x), y: CGFloat(projected.y))
        guard point.x.isFinite, point.y.isFinite else {
            onProject?(nil)
            return
        }
        onProject?(point)
    }
}
