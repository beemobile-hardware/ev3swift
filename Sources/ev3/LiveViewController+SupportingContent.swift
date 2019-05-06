import Foundation
import CoreMotion

extension LiveViewController {
    /*
     This is trying to replicate playground experience. I put in if def because I modified the Playground Support framework to change one of the proxy inits from internal to public. Since the playground app is using it's own version, need to make sure that init code isn't called.
     */
    func setupSupportingContent() {
        loadedFromPlayground = false
        mockRemoteLiveViewProxy = DefaultMockRemoteLiveViewProxy()
        mockRobot = Robot(mockProxy: mockRemoteLiveViewProxy)
        mockRobot?._mockProxy = mockRemoteLiveViewProxy
        mockRemoteLiveViewProxy?.delegate = mockRobot
        mockRemoteLiveViewProxy?.messageHandler = self
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.mockRobotThread = Thread(block: {
                self.runProgram()
            })
            self.mockRobotThread?.start()
        }
    }
    
    func runProgram() {
        guard let robot = mockRobot, (communicationLayer?.isConnected)! else {
            log(message: "Not connected")
            sleep(5)
            runProgram()
            return
        }

        robot.resetAll()
        
        log(message: "Running test program...")
        
        testWaitForMotor(robot: robot, leftPort: .a, rightPort: .b)
        testUltraSonic(with: robot, at: .three)
        testGyro(with: robot, on: .one)
        testWaitForColor(robot: robot, on:.four)
        testWaitForDistance(robot: robot, on: .one)
        testWaitForTouch(robot: robot, on: .two)
        testSoundFiles(robot: robot)
        testSound(with: robot)
        testMotor(with: robot, at: .a)
        testTank(with: robot, leftPort: .a, rightPort: .b)
        testMotorSensorData(with: robot, port: .a)
        testDisplay(robot: robot)
        
        robot.restoreDisplay()
    }
    
    func testWaitForMotor(robot: RobotAPI, leftPort: OutputPort, rightPort: OutputPort) {
        //Move forwards indefinitely
        robot.move(leftPort: leftPort, rightPort: rightPort, leftPower: 40, rightPower: 40)
    
        //Block until 3 rotations
        robot.waitForMotorRotations(on: leftPort, greaterThanOrEqualTo: 3)
        
        //Stop motors and play sound
        robot.stopMove(leftPort: leftPort, rightPort: rightPort, withBrake: true)
        robot.playSound(frequency: 440, forSeconds: 0.5, atVolume: 20)
        
        //Move backwards indefinitely
        robot.move(leftPort: leftPort, rightPort: rightPort, leftPower: -40, rightPower: -40)
        
        //Block until motor is blocked (i.e. hit a wall)
        robot.waitForMotorPower(on: leftPort, lessThanOrEqualTo: 0)
        
        //Turn motors off and play another sound
        robot.stopMove(leftPort: leftPort, rightPort: rightPort, withBrake: true)
        robot.playSound(frequency: 880, forSeconds: 0.5, atVolume: 20)
    }

    
    func stressTest(robot: RobotAPI) {
        
        func rndInt(max: Int) -> Int {
            return Int(random(max: Float(max)))
        }
        
        func readRandomUltrasonic() {
            switch rndInt(max: 2) {
                case 0: _ = robot.measureUltrasonicCentimeters(on: .four)
                case 1: _ = robot.measureUltrasonicInches(on: .four)
                default: break
            }
        }
        
        func readRandomLight() {
            switch rndInt(max: 3) {
                case 0: _ = robot.measureLightColor(on: .three)
                case 1: _ = robot.measureLightAmbient(on: .three)
                case 2: _ = robot.measureLightReflection(on: .three)
                default: break
            }
        }
        
        func readRandomGyro(){
            switch rndInt(max: 2){
                case 0: _ = robot.measureGyroAngle(on: .two)
                case 1: _ = robot.measureGyroRate(on: .two)
                default: break
            }
        }
        
        func readRandomTouch(){
            switch rndInt(max: 2) {
                case 0: _ = robot.measureTouch(on: .one)
                case 1: _ = robot.measureTouchCount(on: .one)
                default: break
            }
        }

        func readRandomInput(){
            switch rndInt(max: 4) {
                case 0: readRandomTouch()
                case 1: readRandomGyro()
                case 2: readRandomLight()
                case 3: readRandomUltrasonic()
                default: break
            }
        }
        
        func moveMotor(on port: OutputPort) {
            switch rndInt(max: 4) {
                case 0: robot.motorOn(on: port, withPower: random(max: 30))
                case 1: robot.motorOff(on: port)
                case 2: robot.motorOn(forDegrees: random(max: 360.0), on: port, withPower: random(max: 30))
                case 3: robot.motorOn(forRotations: random(max: 3), on: port, withPower: random(max: 70))
                default: break
            }
        }
        
        func moveRandomMotor(){
            switch rndInt(max: 4) {
                case 0: moveMotor(on: .a)
                case 1: moveMotor(on: .b)
                case 2: moveMotor(on: .c)
                case 3: moveMotor(on: .d)
            default: break
            }
        }
        
        while true {
            switch rndInt(max: 2) {
                case 0: moveRandomMotor()
                case 1: readRandomInput()
                default: break
            }
        }
    }
    
    func testWaitForTouch(robot: RobotAPI, on port: InputPort) {
        robot.waitForTouch(on: port)
        robot.playSound(frequency: 440, forSeconds: 0.5, atVolume: 10)
        
        robot.waitForTouchReleased(on: port)
        robot.playSound(frequency: 880, forSeconds: 0.5, atVolume: 10)
        
        robot.waitForTouchCount(on: port, greaterThanOrEqualTo: 10)
        robot.playSound(frequency: 440, forSeconds: 0.5, atVolume: 10)
    }
    
    func testWaitForDistance(robot: RobotAPI, on port: InputPort) {
        robot.waitForUltrasonicCentimeters(on: port, lessThanOrEqualTo: 20)
        robot.playSound(frequency: 440, forSeconds: 0.5, atVolume: 10)
    }

    func testMotor(with robot: RobotAPI, at port: OutputPort) {
        robot.motorOn(on: port, withPower: 30)
        sleep(1)
        robot.motorOff(on: port, brakeAtEnd: false)
        
        //Turn on for 2 rotations in each direction
        robot.motorOn(forDegrees: 2, on: port, withPower: 30, brakeAtEnd: true)
        
        robot.motorOn(forRotations: -2, on: port, withPower: 30, brakeAtEnd: true)

        for c in 1 ... 5 {
            print("Moving motor \(c * 90)")
            robot.motorOn(forDegrees: Float(c * 90), on: port, withPower: 40, brakeAtEnd: true)
            print("Moving motor \(-c * 90)")
            robot.motorOn(forDegrees: Float(-c * 90), on: port, withPower: 40, brakeAtEnd: false)
        }
        
        log(message: "motor on test finished")
    }
    
    func testTank(with robot: RobotAPI, leftPort: OutputPort, rightPort: OutputPort) {
        robot.move(forDegrees: 180, leftPort: leftPort, rightPort: rightPort, leftPower: 20, rightPower: -20)
        log(message: "sent turn right for 180 degrees")
        robot.move(forRotations: 1, leftPort: leftPort, rightPort: rightPort, leftPower: -30, rightPower: 30)
        log(message: "sent turn left for 1 rotation")
        robot.move(forSeconds: 1, leftPort: leftPort, rightPort: rightPort, leftPower: 30, rightPower: 20)
        log(message: "sent move ahead and slightly right for 1 second")
        robot.move(leftPort: leftPort, rightPort: rightPort, leftPower: -30, rightPower: -20)
        log(message: "sent move back and slightly left")
        sleep(1)
        log(message: "slept for 1 second")
        robot.stopMove(leftPort: leftPort, rightPort: rightPort, withBrake: true)
        log(message: "sent stop motors")
    }
    
    func testMotorSensorData(with robot: Robot, port: OutputPort) {
        log(message: "motor power is (start) \(robot.measureMotorPower(on: port))")
        for i in 1 ... 10 {
            let power = Float(i) * 10.0
            robot.motorOn(on: port, withPower: power)
            sleep(1)
            log(message: "motor power is \(robot.measureMotorPower(on: port)) should be \(power)")
        }
        sleep(1)
        robot.motorOff(on: port)
        log(message: "motor power is (end) \(robot.measureMotorPower(on: port))")
        
        for _ in 1 ... 5 {
            robot.motorOn(forRotations: 1, on: port, withPower: 30)
            log(message: "motor rotations is \(robot.measureMotorRotations(on: port))")
            log(message: "motor degrees is \(robot.measureMotorDegrees(on: port))")
        }
        robot.motorOff(on: port)
    }
    
    func testUltraSonic(with robot: RobotAPI, at port: InputPort) {
        for _ in 1 ... 10
        {
            log(message: "read distance \(robot.measureUltrasonicCentimeters(on: port)) cm")
            sleep(1)
        }
        for _ in 1 ... 10
        {
            log(message: "read distance \(robot.measureUltrasonicInches(on: port)) inches")
            testGyro(with: robot, on: .one)
        }
    }
    
    func testGyro(with robot: RobotAPI, on port: InputPort) {
        for _ in 1 ... 10 {
            log(message:"Gyro angle: \(robot.measureGyroAngle(on: port))")
            sleep(1)
        }
        for _ in 1 ... 10 {
            log(message:"Gyro rate: \(robot.measureGyroRate(on: port))")
            sleep(1)
        }
    }
    
    func testWaitForColor(robot: RobotAPI, on port: InputPort) {
        robot.waitForLightColor(on: port, color: .yellow)
        robot.playSound(frequency: 440, forSeconds: 0.5, atVolume: 10)
    }
    
    func testSoundFiles(robot: RobotAPI) {
        let sounds: [SoundFile] = [
            .hello,
            .goodbye,
            .fanfare,
            .errorAlarm,
            .start,
            .stop,
            .object,
            .ouch,
            .blip,
            .arm,
            .snap,
            .laser,
            ]
        for s in sounds {
            robot.playSound(file: s, atVolume: 10, withStyle: .playOnce)
            sleep(2)
        }
        robot.stopSound()
    }
    
    func testSound(with robot: RobotAPI) {
        for f in [250, 1500, 2500, 3750, 5000, 6000, 7000, 8000, 9000, 10000] {
            robot.playSound(frequency: Float(f), forSeconds: 0.5, atVolume: 10)
        }
        let notes: [Note] = [.c5, .d5, .e5, .f5, .g5, .a5, .b5]
        for n in notes {
            robot.playSound(note: n, forSeconds: 0.5, atVolume: 10)
        }
    }

    func testDisplay(robot: RobotAPI) {
        let images:[ImageName] = [
            .neutral,
            .pinchRight,
            .awake,
            .hurt,
            .accept,
            .decline,
            .questionMark,
            .warning,
            .stop,
            .pirate,
            .boom,
            .ev3Icon
        ]
        
        let delayTime = useconds_t(500000)
        
        for image in images {
            robot.displayImage(named: image, atX: 0, atY: 0, clearScreen: true)
            usleep(delayTime)
        }
        
        let colors: [BrickLightColor] = [.green, .red, .orange]
        let modes: [BrickLightMode] = [.on, .flashing, .pulsating]
        
        for color in colors {
            for mode in modes {
                robot.brickLightOn(withColor: color, inMode: mode)
                sleep(2)
            }
        }
        
        (robot as! Robot).hideTopBar()
        robot.display(text: "Hello", atX:  5, atY: 5, withColor: .black, withFont: .normal, clearScreen: true)
        usleep(delayTime)
        
        robot.displayPoint( atX: 10, atY: 10, withColor: .black, clearScreen: true)
        robot.displayPoint( atX: 40, atY: 70, withColor: .black, clearScreen: false)
        robot.displayPoint( atX: 45, atY: 20, withColor: .black, clearScreen: false)
        robot.displayPoint( atX: 20, atY: 80, withColor: .black, clearScreen: false)
        robot.displayPoint( atX: 89, atY:20, withColor: .black, clearScreen: false)
        
        usleep(delayTime)
        
        robot.displayCircle(centerX: 15, centerY:10, withRadius: 10, withFill: false, withColor: .black, clearScreen: true)
        usleep(delayTime)
        
        robot.displayCircle(centerX: 15, centerY:10, withRadius: 10, withFill: true, withColor: .black, clearScreen: true)
        usleep(delayTime)
        
        robot.displayLine( fromX: 0, fromY:0, toX: 20, toY:20, withColor: .black, clearScreen: true)
        usleep(delayTime)
        
        robot.displayRectangle( atX: 5, atY: 5, length: 20, height: 10, withFill: false, withColor: .black, clearScreen: true)
        usleep(delayTime)
        
        robot.displayRectangle( atX: 5, atY:5, length: 20, height: 10, withFill: true, withColor: .black, clearScreen: true)
        usleep(delayTime)

        (robot as! Robot).showTopBar()
        robot.brickLightOff()
    }
    
}
