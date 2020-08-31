//
//  ViewController.swift
//  TestLoadScene
//
//  Created by 曾宪杰 on 2020/8/31.
//  Copyright © 2020 X.x. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet weak var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        setupARView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadRealityComposerSceneAsync(filename: "TestScene", fileExtension: "reality", sceneName: "space") { result in
            switch result {
            case .success(let anchor):
                print("space is \(anchor)\n")
                // anchor -> (Entity & HasAnchoring)?
                // it's crash...Thread 1: EXC_BAD_ACCESS (code=1, address=0x40)
                self.arView.scene.addAnchor(anchor)
                
                break
                
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
        
    }
    
    
    var streams = [Combine.AnyCancellable]()
    func loadRealityComposerSceneAsync (filename: String,
                                        fileExtension: String,
                                        sceneName: String,
                                        completion: @escaping (Swift.Result<(Entity & HasAnchoring), Swift.Error>) -> Void) {
        
        guard let realityFileSceneURL = createRealityURL(filename: filename, fileExtension: fileExtension, sceneName: sceneName) else {
            print("Error: Unable to find specified file in application bundle")
            return
        }
        
        let loadRequest = Entity.loadAnchorAsync(contentsOf: realityFileSceneURL)
        
        let cancellable = loadRequest.sink(receiveCompletion: { (loadCompletion) in
            if case let .failure(error) = loadCompletion {
                completion(.failure(error))
            }
        }, receiveValue: { (entity) in
            //  entity AnchorEntity
            completion(.success(entity))
        })
        cancellable.store(in: &streams)
    }
    
    //
    func createRealityURL(filename: String,
                          fileExtension: String,
                          sceneName:String) -> URL? {
        // Create a URL that points to the specified Reality file.
        guard let realityFileURL = Bundle.main.url(forResource: filename,
                                                   withExtension: fileExtension) else {
                                                    print("Error finding Reality file \(filename).\(fileExtension)")
                                                    return nil
        }
        
        // Append the scene name to the URL to point to
        // a single scene within the file.
        let realityFileSceneURL = realityFileURL.appendingPathComponent(sceneName,
                                                                        isDirectory: false)
        return realityFileSceneURL
    }
    
    func setupARView() {
        arView.automaticallyConfigureSession = true
        arView.cameraMode = ARView.CameraMode.ar
        if (ARConfiguration.isSupported) {
//               arView.session.delegate = self
            arView.session.run(arConfiguration)
            
        }
        
    }
    
    lazy var arConfiguration:ARWorldTrackingConfiguration = {
        var arWorldTracking = ARWorldTrackingConfiguration.init()
        arWorldTracking.planeDetection = .horizontal
        arWorldTracking.isLightEstimationEnabled = true
        arWorldTracking.automaticImageScaleEstimationEnabled = true
        return arWorldTracking
    }()
    
    
}

