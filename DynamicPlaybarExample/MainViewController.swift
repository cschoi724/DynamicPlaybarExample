 //
//  ViewController.swift
//  DynamicPlaybarExample
//
//  Created by cschoi on 12/20/23.
//

import UIKit
import FlexLayout
import PinLayout

class MainViewController: UIViewController {
    fileprivate lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cyan
        return view
    }()
    fileprivate lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .magenta
        view.isHidden = true
        return view
    }()
    fileprivate lazy var toolbarView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        let home = UIButton()
        home.backgroundColor = .green
        let mypage = UIButton()
        mypage.backgroundColor = .red
        view.flex.direction(.row).define { flex in
            flex.addItem(home).grow(1)
            flex.addItem(mypage).grow(1)
        }
        return view
    }()
    fileprivate lazy var showLiveBtn: UIButton = {
        let view = UIButton()
        view.backgroundColor = .lightGray
        view.setTitle("Play", for: .normal)
        view.setTitleColor(.black, for: .normal)
        return view
    }()
    fileprivate lazy var playerViewController: PlayViewController = {
        let vc = PlayViewController()
        return vc
    }()

    var panGesture: UIPanGestureRecognizer!
    private var positionRate: CGFloat = 1
    private var startPos: CGFloat = 0
    private var breakpoint: CGFloat {
        return playerViewController.view.frame.height
        - toolbarView.frame.height
        - 60
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(containerView)
        view.addSubview(overlayView)
        view.addSubview(toolbarView)
        containerView.addSubview(showLiveBtn)
        showLiveBtn.addTarget(self, action: #selector(showLive), for: .touchUpInside)
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(onTrasition))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.all()
        showLiveBtn.pin.hCenter().vCenter().margin(12, 12, 12, 12).sizeToFit()
        overlayView.pin.all()
        toolbarView.pin.bottom().left().right().height(88)
        toolbarView.flex.layout()
    }
    
    @objc func showLive() {
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.pin.all()
        playerViewController.view.addGestureRecognizer(panGesture)
        //present(playerViewController, animated: true)
    }
    
    @objc func onTrasition(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: playerViewController.view)
        let velocity = gesture.velocity(in: view)
        let height = playerViewController.view.frame.height
        
        switch gesture.state {
        case .began:
            break
        case .changed:
            positionRate = (startPos + translation.y) / height
            updateFrame()
            gesture.setTranslation(translation, in: playerViewController.view)
        case .ended:
            startPos += translation.y
            if velocity.y > 0 {
                startPos = breakpoint
                enterMinimize()
            } else {
                startPos = 0
                enterFullScreen()
            }
        default:
            break
        }
    }
    
    private func updateFrame() {
        updateChildFrame()
        updateToolbarFrame()
        updateVideoFrame()
    }
    
    private func updateChildFrame() {
        let rate = min(max(positionRate, 0), 1)
        let endpoint = breakpoint
        let vector = endpoint * rate
        playerViewController.view.pin.top(vector).bottom(-vector).left().right()
        playerViewController.bodyView.alpha = 1 - (rate * 2)
    }
    
    private func updateToolbarFrame() {
        let rate = min(max(positionRate, 0), 1)
        let height = toolbarView.frame.height
        if rate <= 0.5 {
            let toolbarRate = min(max(1 - (rate * 2), 0), 1)
            let vector = height * toolbarRate
            toolbarView.pin.bottom(-vector).left().right()
        } else {
            toolbarView.pin.bottom(0).left().right()
        }
    }
    
    private func updateVideoFrame() {
        let startPoint = breakpoint - playerViewController.screenView.frame.height
        let offset = playerViewController.view.frame.origin.y
        let rate = min(max(offset - startPoint, 0) / playerViewController.screenView.frame.height, 1)
        let right = (playerViewController.screenView.frame.width - 104) * rate
        let bottom = (playerViewController.screenView.frame.height - 60) * rate
        playerViewController.videoView.pin.top().left().bottom(bottom).right(right)
        playerViewController.playbarView.alpha = rate
    }
    
    func enterFullScreen() {
        positionRate = 0
        startPos = 0
        UIView.animate(
            withDuration: 0.25,
            animations: { [weak self] in
                self?.updateFrame()
            }
        )
    }

    func enterMinimize() {
        positionRate = 1
        startPos = breakpoint
        UIView.animate(
            withDuration: 0.25,
            animations: { [weak self] in
                self?.updateFrame()
            }
        )
    }
}

