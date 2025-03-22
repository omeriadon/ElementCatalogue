import SwiftUI
import SceneKit

// Create a cross-platform atomic model view implementation
struct AtomicModelView: View {
    let element: ElementData
    
    var body: some View {
        AtomicModelSceneView(element: element)
    }
}

// The actual SceneKit implementation for macOS
struct AtomicModelSceneView: NSViewRepresentable {
    let element: ElementData
    
    func makeNSView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = createAtomScene()
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = NSColor.black
        
        // Set proper defaults for viewport
        sceneView.pointOfView?.position = SCNVector3(x: 0, y: 0, z: 5) // Position camera
        sceneView.antialiasingMode = .multisampling4X // Improve quality
        
        // Start animation
        rotateAtom(sceneView: sceneView)
        
        return sceneView
    }
    
    func updateNSView(_ sceneView: SCNView, context: Context) {
        // Update if needed
        if let scene = sceneView.scene {
            // Adjust electron count if element changes
            updateElectrons(scene: scene)
        }
    }
    
    private func createAtomScene() -> SCNScene {
        let scene = SCNScene()
        
        // Create nucleus
        let nucleusGeometry = SCNSphere(radius: 0.5)
        
        let nucleusMaterial = SCNMaterial()
        let nucleusColor = ElementColors.colorForElement(element)
        nucleusMaterial.diffuse.contents = NSColor(red: nucleusColor.components.red, 
                                                 green: nucleusColor.components.green,
                                                 blue: nucleusColor.components.blue,
                                                 alpha: 1.0)
        nucleusMaterial.specular.contents = NSColor.white
        nucleusGeometry.materials = [nucleusMaterial]
        
        let nucleusNode = SCNNode(geometry: nucleusGeometry)
        scene.rootNode.addChildNode(nucleusNode)
        
        // Create electron shells based on element's electron configuration
        let shells = element.shells
        
        for (index, electronCount) in shells.enumerated() {
            let shellRadius = Double(index + 1) * 1.2
            addElectronShell(to: scene.rootNode, radius: shellRadius, electronCount: electronCount)
        }
        
        return scene
    }
    
    private func addElectronShell(to rootNode: SCNNode, radius: Double, electronCount: Int) {
        // Create shell (orbit path)
        let shellGeometry = SCNTorus(ringRadius: CGFloat(radius), pipeRadius: 0.01)
        let shellMaterial = SCNMaterial()
        shellMaterial.diffuse.contents = NSColor.gray.withAlphaComponent(0.5)
        shellGeometry.materials = [shellMaterial]
        
        let shellNode = SCNNode(geometry: shellGeometry)
        
        // Rotate the shell to create 3D appearance
        shellNode.rotation = SCNVector4(1, 0, 0, Float.pi / 3)
        rootNode.addChildNode(shellNode)
        
        // Add electrons to the shell
        let angleIncrement = 2 * Double.pi / Double(electronCount)
        
        for i in 0..<electronCount {
            let electronGeometry = SCNSphere(radius: 0.1)
            let electronMaterial = SCNMaterial()
            electronMaterial.diffuse.contents = NSColor.cyan
            electronMaterial.specular.contents = NSColor.white
            electronGeometry.materials = [electronMaterial]
            
            let electronNode = SCNNode(geometry: electronGeometry)
            
            // Position electron on the orbit
            let angle = Double(i) * angleIncrement
            electronNode.position = SCNVector3(
                x: CGFloat(Float(radius * cos(angle))),
                y: 0,
                z: CGFloat(Float(radius * sin(angle)))
            )
            
            // Apply rotation to match shell orientation
            electronNode.rotation = shellNode.rotation
            
            // Add to scene
            rootNode.addChildNode(electronNode)
            
            // Animate the electron around its shell
            animateElectron(electronNode: electronNode, radius: radius, initialAngle: angle)
        }
    }
    
    private func animateElectron(electronNode: SCNNode, radius: Double, initialAngle: Double) {
        // Orbit animation
        let orbitAction = SCNAction.customAction(duration: 5.0 * (radius / 2.0)) { (node, elapsedTime) in
            let angle = initialAngle + Double(elapsedTime) * 2 * Double.pi / 5.0
            node.position = SCNVector3(
                x: CGFloat(Float(radius * cos(angle))),
                y: node.position.y,
                z: CGFloat(Float(radius * sin(angle)))
            )
        }
        
        electronNode.runAction(SCNAction.repeatForever(orbitAction))
    }
    
    private func rotateAtom(sceneView: SCNView) {
        // Slow rotation of the entire atom
        if let node = sceneView.scene?.rootNode {
            let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi/4), z: 0, duration: 10)
            let repeatRotation = SCNAction.repeatForever(rotation)
            node.runAction(repeatRotation)
        }
    }
    
    private func updateElectrons(scene: SCNScene) {
        // Update electron configuration if needed
        // This would be implemented if we need to update the model when the element changes
    }
}

// Helper extension for Color components access
extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        guard let color = NativeColor(self).usingColorSpace(.deviceRGB) else {
            return (0, 0, 0, 0)
        }
        color.getRed(&r, green: &g, blue: &b, alpha: &o)
        
        return (r, g, b, o)
    }
}
