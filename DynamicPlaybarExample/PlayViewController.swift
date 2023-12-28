//
//  PlayViewController.swift
//  DynamicPlaybarExample
//
//  Created by cschoi on 12/26/23.
//

import UIKit
import FlexLayout
import PinLayout

class PlayViewController: UIViewController {
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    lazy var screenView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    lazy var playbarView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    lazy var videoView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        return view
    }()
    lazy var bodyView: UIView = {
        let view = UIView()
        view.backgroundColor = .brown
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(containerView)
        containerView.addSubview(screenView)
        containerView.addSubview(bodyView)
        screenView.addSubview(playbarView)
        screenView.addSubview(videoView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.all()
        screenView.pin.top().left().right().aspectRatio(1.73621)
        bodyView.pin.bottom().right().left().below(of: screenView)
        playbarView.pin.top().left().right().height(60)
        videoView.pin.top().left().right().bottom()
    }
}
