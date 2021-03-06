//
//  GameScene.swift
//  kursv2
//
//  Created by Артем on 29/11/2018.
//  Copyright © 2018 Артем. All rights reserved.
//

import SpriteKit
import GameplayKit
var isStatistic :Bool = false
var isStart :Bool = true
struct NumPress {
    public var hit :Int = 0
    public var press :Int = 0
}
var arrayNumPress = Array<Array<NumPress>>()
var allNumPress:NumPress = NumPress.init()
class GameScene: SKScene {
    private var object : SKShapeNode?
    private var spinnyNode : SKShapeNode?
    let rowDisplay = 8
    let columnDisplay = 8
    var numColumnPoint : CGFloat = 0
    var numRowPoint :CGFloat = 0
    private var ScoreLabel :SKLabelNode?
    override func didMove(to view: SKView) {
        numColumnPoint = self.size.width / CGFloat(columnDisplay)
        numRowPoint = self.size.height / CGFloat(rowDisplay)
        
        if isStatistic {
            
            initializationStatstic()
        } else {
            if isStart{
                initializationStart()
                initializateContinue()
            } else {
                initializateContinue()
            }
            
        }
    }
    func initializationStart() {
        //Обнуляем либо создаем статистику заново
        if !arrayNumPress.isEmpty {
            arrayNumPress.removeAll()
        }
        for _ in 0..<columnDisplay {
            var columnArray = Array<NumPress>()
            for _ in 0..<rowDisplay
            {
                columnArray.append(NumPress.init())
            }
            arrayNumPress.append(columnArray)
        }
        allNumPress.hit = 0
        allNumPress.press = 0
        
    }
    func initializateContinue() {
        object = createObjects()
        self.addChild(object!)
        ScoreLabel = SKLabelNode.init(text: "Procent: \(allNumPress.press == 0 ? 0 : Int(round(Double(allNumPress.hit)/Double(allNumPress.press) * 100))) %")
        ScoreLabel?.zPosition = 1
        ScoreLabel?.position = CGPoint.init(x: 0.0, y: self.size.height/2 - (ScoreLabel?.calculateAccumulatedFrame().height)! - 15)
        self.addChild(ScoreLabel!)
        for i in 0...columnDisplay{
            for j in 0...rowDisplay{
                let obj = SKShapeNode.init(rect: CGRect.init(x: CGFloat(i - columnDisplay/2) * numColumnPoint, y: CGFloat(j - rowDisplay/2) * numRowPoint, width: numColumnPoint, height: numRowPoint))
                obj.fillColor = UIColor.darkGray
                obj.zPosition = -0.5
                self.addChild(obj)
                
                
            }
        }
    }
    func initializationStatstic(){
        if !(numRowPoint == 0.0 || numColumnPoint == 0.0){
            if arrayNumPress.count == 0{
                return
            }
            for i in 0..<columnDisplay{
                for j in 0..<rowDisplay{
                    let obj = SKShapeNode.init(rect: CGRect.init(x: CGFloat(i - columnDisplay/2) * numColumnPoint,
                                                                 y: CGFloat(rowDisplay - 1 - j - rowDisplay/2) * numRowPoint, width: numColumnPoint, height: numRowPoint))
                    obj.fillColor = UIColor.darkGray
                    obj.zPosition = 0.5
                    let stringLabel = String(arrayNumPress[i][j].press == 0 ? 0: Int(round(Double(arrayNumPress[i][j].hit)/Double(arrayNumPress[i][j].press) * 100))) + "% \n" +  String(arrayNumPress[i][j].press)
                    let myLabel = SKLabelNode.init(text: stringLabel)
                    myLabel.fontColor = UIColor.green
                    myLabel.numberOfLines = 2
                    myLabel.position = CGPoint.init(x: obj.frame.midX, y: obj.frame.midY)
                    myLabel.zPosition = 1
                    myLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
                    self.addChild(obj)
                    self.addChild(myLabel)
                    print("\(i) \(j) \(arrayNumPress[i][j].hit) \(arrayNumPress[i][j].press)")
                    
                }
            }
        }
        
    }
    func randColor() -> SKColor {
        return SKColor.init(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: CGFloat.random(in: 0...1))
    }
    func minPressInSector() -> Int {
        let min = arrayNumPress.min(by: {(a, b) -> Bool in
            return a.min(by: {(i,k) -> Bool in return i.press < k.press})!.press <
                   b.min(by: {(i,k) -> Bool in return i.press < k.press})!.press
        })?.min(by: {(a,b) -> Bool in return a.press < b.press})!
        
        return (min?.press)!
    }
    func createObjects() -> SKShapeNode{
        let radius = CGFloat.random(in: 40...50)
        let object = SKShapeNode.init(circleOfRadius: radius)
        object.fillColor = randColor()
        object.zPosition = 1.0
        let noty = ScoreLabel?.calculateAccumulatedFrame().height ?? 0
        var (sectorX, sectorY) = (0, 0)
        let minIsSector = minPressInSector()
        print("min \(minIsSector)")
        for _ in 0...1000 {
            let x = CGFloat.random(in: -self.size.width/2 + radius ... self.size.width/2 - radius)
            let y = CGFloat.random(in: -self.size.height/2 + radius ... self.size.height/2 - radius - noty)
            object.position = CGPoint(x: x, y: y)
            (sectorX, sectorY) = defineSector(object: object)
            if arrayNumPress[sectorX][sectorY].press == minIsSector{
                print("OK")
                return object
            }
        }
        //Testing
        return object
    }
    func defineSector(object:SKShapeNode?) -> (Int, Int) { //Переписать
        var sectorX = 0
        var sectorY = 0
        for i in 1...columnDisplay{
            if (((object?.frame.midX)! < (CGFloat(i-columnDisplay/2) * numColumnPoint)) &&
                ((object?.frame.midX)! > (CGFloat(i-1 - columnDisplay/2) * numColumnPoint))) ||
                (((object?.frame.midX)! > (CGFloat(i-columnDisplay/2) * numColumnPoint)) &&
                    ((object?.frame.midX)! < (CGFloat(i-1 - columnDisplay/2) * numColumnPoint)))
            {
                sectorX = i-1
                break
            }
        }
        for i in 1...rowDisplay{
            if (((object?.frame.midY)! < (CGFloat(i - rowDisplay/2) * numRowPoint)) &&
                ((object?.frame.midY)! > (CGFloat(i-1 - rowDisplay/2) * numRowPoint))) ||
                (((object?.frame.midY)! > (CGFloat(i-rowDisplay/2) * numRowPoint)) &&
                    ((object?.frame.midY)! < (CGFloat(i-1 - rowDisplay/2) * numRowPoint)))
            {
                sectorY = rowDisplay - i
                break
            }
        }
        return (sectorX, sectorY)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("10")
        if  self.object != nil  {
            let locationTouch = (touches.first?.location(in: self))!
            //Координаты с середины, следовательно отсчитываем координаты от середины
            let (sectorX, sectorY) = defineSector(object: object)
            if isInside(a: locationTouch, b: self.object!) {
                allNumPress.hit += 1
                arrayNumPress[sectorX][sectorY].hit += 1
            }
            allNumPress.press += 1
            arrayNumPress[sectorX][sectorY].press += 1
            object?.removeFromParent()
            object = createObjects()
            self.addChild(object!)
            if ScoreLabel != nil{
                ScoreLabel!.text="Procent: \(allNumPress.press == 0 ? 0 : Int(round(Double(allNumPress.hit)/Double(allNumPress.press) * 100))) %  \(minPressInSector())"
            }
        }
        
        
    }
    func roundX(a:CGFloat) -> Int {
        if a < 0{
            return lroundf( Float(a-0.5) )
        } else{
            return lroundf(Float(a))
        }
    }
    func roundY(a:CGFloat) -> Int {
        if a < 0{
            return lroundf( Float(a) )
        } else{
            return lroundf(Float(a+0.5))
        }
    }
    func isInside(a: CGPoint, b: SKShapeNode) -> Bool {
        if (b.position.x - b.calculateAccumulatedFrame().width)...(b.position.x + b.calculateAccumulatedFrame().width)  ~= a.x {
            if (b.position.y - b.calculateAccumulatedFrame().height)...(b.position.y + b.calculateAccumulatedFrame().height)  ~= a.y {
                return true
            }
        }
        
        return false
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
