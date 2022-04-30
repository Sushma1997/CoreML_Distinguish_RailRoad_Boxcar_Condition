
import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    //deriving properties
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var imagePickerController: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        controller.allowsEditing = false
        return controller
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "click on the camera button"
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBarButtonItem()
    }
    
    //we have button to show camera icon
    private func setupBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera.fill"), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    //to access pictures in camera
    @objc
    private func handleCamera() {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func setupUI() {
        self.view.backgroundColor = .white
        
        //image view to display the selected image
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        //lable to show the accuracy
        view.addSubview(infoLabel)
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: TrainingImages_2.init(configuration: MLModelConfiguration()).model) else {
            fatalError("Loading the model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Mode failed to process image")
            }
            
            if let resultString = results.first?.identifier {
                self.title = resultString
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            request.usesCPUOnly = true //this command to make it work on M1 chip
            try handler.perform([request])
        } catch {
            print("Failed to perform request with error")
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            
            guard let ciImage = CIImage(image: image) else {
                return
            }
            
            dismiss(animated: true, completion: nil)
            infoLabel.isHidden = true
            detect(image: ciImage)
            
        }
        
        dismiss(animated: true, completion: nil)
    }
}
