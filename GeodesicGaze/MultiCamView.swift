import SwiftUI
import AVFoundation
import MetalKit

struct MultiCamView: UIViewControllerRepresentable {
    class Coordinator: NSObject, MultiCamCaptureDelegate {
        var parent: MultiCamView
        var mixer: BhiMixer
        var mtkView: MTKView
        var multiCamCapture: MultiCamCapture

        init(parent: MultiCamView, mtkView: MTKView, mixer: BhiMixer, multiCamCapture: MultiCamCapture) {
            self.parent = parent
            self.mtkView = mtkView
            self.mixer = mixer
            self.multiCamCapture = multiCamCapture
        }
        
        func processCameraPixelBuffers(frontCameraPixelBuffer: CVPixelBuffer, backCameraPixelBuffer: CVPixelBuffer) {
            mixer.mix(frontCameraPixelBuffer: frontCameraPixelBuffer,
                      backCameraPixelBuffer: backCameraPixelBuffer,
                      in: mtkView)
        }
    }

    func makeCoordinator() -> Coordinator {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.framebufferOnly = false
        let mixer = BhiMixer(device: mtkView.device!)
        let multiCamCapture = MultiCamCapture()
        
        return Coordinator(parent: self, mtkView: mtkView, mixer: mixer, multiCamCapture: multiCamCapture)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        let videoViewHeight = viewController.view.bounds.height / 3
        
        // Configure the views.
        let frontView = UIView(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.width, height: videoViewHeight))
        let backView = UIView(frame: CGRect(x: 0, y: videoViewHeight, width: viewController.view.bounds.width, height: videoViewHeight))
        let mtkView = context.coordinator.mtkView
        mtkView.frame = CGRect(x: 0, y: 2 * videoViewHeight, width: viewController.view.bounds.width, height: videoViewHeight)
        
        viewController.view.addSubview(frontView)
        viewController.view.addSubview(backView)
        viewController.view.addSubview(mtkView)

       
        let multiCamCapture = context.coordinator.multiCamCapture
        multiCamCapture.setupPreviewLayers(frontView: frontView, backView: backView)
        multiCamCapture.delegate = context.coordinator
        multiCamCapture.startRunning()

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the UI view controller if needed
    }
}