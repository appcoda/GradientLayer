//
//  ViewController.swift
//  GradientLayer
//
//  Created by Simon Ng on 26/7/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var gradientLayer: CAGradientLayer!

    var colorSets = [[CGColor]]()
    
    var currentColorSet: Int!
    
    enum PanDirections: Int {
        case Right
        case Left
        case Bottom
        case Top
        case TopLeftToBottomRight
        case TopRightToBottomLeft
        case BottomLeftToTopRight
        case BottomRightToTopLeft
    }
    
    var panDirection: PanDirections!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        createColorSets()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTapGesture(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        let twoFingerTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTwoFingerTapGesture(_:)))
        twoFingerTapGestureRecognizer.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(twoFingerTapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePanGestureRecognizer(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        createGradientLayer()
    }
    
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = colorSets[currentColorSet]
        gradientLayer.locations = [0.0, 0.35]
        
        gradientLayer.startPoint = CGPointMake(0.0, 0.5)
        gradientLayer.endPoint = CGPointMake(1.0, 0.5)
        
        self.view.layer.addSublayer(gradientLayer)
    }
    
    func createColorSets() {
        colorSets.append([UIColor.redColor().CGColor, UIColor.yellowColor().CGColor])
        colorSets.append([UIColor.greenColor().CGColor, UIColor.magentaColor().CGColor])
        colorSets.append([UIColor.grayColor().CGColor, UIColor.lightGrayColor().CGColor])
        
        currentColorSet = 0
    }
    
    func handleTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        if currentColorSet < colorSets.count - 1 {
            currentColorSet! += 1
        }
        else {
            currentColorSet = 0
        }
        
        let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
        colorChangeAnimation.duration = 2.0
        colorChangeAnimation.toValue = colorSets[currentColorSet]
        colorChangeAnimation.fillMode = kCAFillModeForwards
        colorChangeAnimation.removedOnCompletion = false
        
        // Add this line to make the ViewController class the delegate of the animation object.
        colorChangeAnimation.delegate = self
        
        gradientLayer.addAnimation(colorChangeAnimation, forKey: "colorChange")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradientLayer.colors = colorSets[currentColorSet]
        }
    }
    
    func handleTwoFingerTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        let secondColorLocation = arc4random_uniform(100)
        let firstColorLocation = arc4random_uniform(secondColorLocation - 1)
        
        gradientLayer.locations = [NSNumber(double: Double(firstColorLocation)/100.0), NSNumber(double: Double(secondColorLocation)/100.0)]
        
        print(gradientLayer.locations!)
    }
    
    func handlePanGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        let velocity = gestureRecognizer.velocityInView(self.view)
        
        if gestureRecognizer.state == UIGestureRecognizerState.Changed {
            if velocity.x > 300.0 {
                // In this case the direction is generally towards Right.
                // Below are specific cases regarding the vertical movement of the gesture.
                
                if velocity.y > 300.0 {
                    // Movement from Top-Left to Bottom-Right.
                    panDirection = PanDirections.TopLeftToBottomRight
                }
                else if velocity.y < -300.0 {
                    // Movement from Bottom-Left to Top-Right.
                    panDirection = PanDirections.BottomLeftToTopRight
                }
                else {
                    // Movement towards Right.
                    panDirection = PanDirections.Right
                }
            }
            else if velocity.x < -300.0 {
                // In this case the direction is generally towards Left.
                // Below are specific cases regarding the vertical movement of the gesture.
                
                if velocity.y > 300.0 {
                    // Movement from Top-Right to Bottom-Left.
                    panDirection = PanDirections.TopRightToBottomLeft
                }
                else if velocity.y < -300.0 {
                    // Movement from Bottom-Right to Top-Left.
                    panDirection = PanDirections.BottomRightToTopLeft
                }
                else {
                    // Movement towards Left.
                    panDirection = PanDirections.Left
                }
            }
            else {
                // In this case the movement is mostly vertical (towards bottom or top).
                
                if velocity.y > 300.0 {
                    // Movement towards Bottom.
                    panDirection = PanDirections.Bottom
                }
                else if velocity.y < -300.0 {
                    // Movement towards Top.
                    panDirection = PanDirections.Top
                }
                else {
                    // Do nothing.
                    panDirection = nil
                }
            }
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            changeGradientDirection()
        }
    }
    
    func changeGradientDirection() {
        if panDirection != nil {
            switch panDirection.rawValue {
            case PanDirections.Right.rawValue:
                gradientLayer.startPoint = CGPointMake(0.0, 0.5)
                gradientLayer.endPoint = CGPointMake(1.0, 0.5)
                
            case PanDirections.Left.rawValue:
                gradientLayer.startPoint = CGPointMake(1.0, 0.5)
                gradientLayer.endPoint = CGPointMake(0.0, 0.5)
                
            case PanDirections.Bottom.rawValue:
                gradientLayer.startPoint = CGPointMake(0.5, 0.0)
                gradientLayer.endPoint = CGPointMake(0.5, 1.0)
                
            case PanDirections.Top.rawValue:
                gradientLayer.startPoint = CGPointMake(0.5, 1.0)
                gradientLayer.endPoint = CGPointMake(0.5, 0.0)
                
            case PanDirections.TopLeftToBottomRight.rawValue:
                gradientLayer.startPoint = CGPointMake(0.0, 0.0)
                gradientLayer.endPoint = CGPointMake(1.0, 1.0)
                
            case PanDirections.TopRightToBottomLeft.rawValue:
                gradientLayer.startPoint = CGPointMake(1.0, 0.0)
                gradientLayer.endPoint = CGPointMake(0.0, 1.0)
                
            case PanDirections.BottomLeftToTopRight.rawValue:
                gradientLayer.startPoint = CGPointMake(0.0, 1.0)
                gradientLayer.endPoint = CGPointMake(1.0, 0.0)
                
            default:
                gradientLayer.startPoint = CGPointMake(1.0, 1.0)
                gradientLayer.endPoint = CGPointMake(0.0, 0.0)
            }
        }
    }
    

}

