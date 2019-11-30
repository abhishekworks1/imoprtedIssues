//
//  StoryContext.swift
//  Camera
//
//  Created by Jasmin Patel on 26/11/18.
//

import Foundation
import CoreGraphics
import CoreImage

public enum StoryContextType: Int {
    /**
     Automatically choose an appropriate StoryContext context
     */
    case auto
    /**
     Create a hardware accelerated StoryContext with Metal
     */
    case metal
    /**
     Create a hardware accelerated StoryContext with CoreGraphics
     */
    case coreGraphics
    /**
     Creates a standard StoryContext hardware accelerated.
     */
    case `default`
    /**
     Create a software rendered StoryContext (no hardware acceleration)
     */
    case cpu
}

class StoryContext: NSObject {
    
    static var StoryContextCIContextOptions: [CIContextOption: Any] {
        return [CIContextOption.workingColorSpace: NSNull(), CIContextOption.outputColorSpace: NSNull()]
    }
    static let StoryContextOptionsCGContextKey = "CGContext"
    static let StoryContextOptionsMTLDeviceKey = "MTLDevice"

    /**
     The CIContext
     */
    private(set) var ciContext: CIContext!
    /**
     The type with with which this StoryContext was created
     */
    private(set) var type: StoryContextType = .default
    /**
     Will be non null if the type is StoryContextTypeMetal
     */
    private(set) var mtlDevice: MTLDevice?
    /**
     Will be non null if the type is StoryContextTypeCoreGraphics
     */
    private(set) var cgContext: CGContext?
    
    init(softwareRenderer: Bool) {
        super.init()
        var options = StoryContext.StoryContextCIContextOptions
        options[CIContextOption.useSoftwareRenderer] = softwareRenderer
        ciContext = CIContext(options: options)
        type = softwareRenderer ? .cpu : .default
    }
    
    init(mtlDevice device: MTLDevice?) {
        super.init()
        mtlDevice = device
        if let device = mtlDevice {
            ciContext = CIContext(mtlDevice: device, options: StoryContext.StoryContextCIContextOptions)
        }
        type = .metal
    }
    
    init(cgContextRef contextRef: CGContext) {
        super.init()
        ciContext = CIContext(cgContext: contextRef, options: StoryContext.StoryContextCIContextOptions)
        type = .coreGraphics
    }
    
    /**
     Returns whether the contextType can be safely created and used using +[StoryContext contextWithType:]
     */
    class func supportsType(_ contextType: StoryContextType) -> Bool {
        let CIContextClass = CIContext.self
        switch contextType {
        case .metal:
            return CIContextClass.responds(to: #selector(CIContext.init(mtlDevice:options:)))
        case .coreGraphics:
            return CIContextClass.responds(to: #selector(CIContext.init(cgContext:options:)))
        case .auto, .default, .cpu:
            return true
        }
    }
    /**
     The context that will be used when using an Auto context type;
     */
    class func suggestedContextType() -> StoryContextType {
        #if !targetEnvironment(simulator)
        if StoryContext.supportsType(.metal) {
            return .metal
        } else if StoryContext.supportsType(.coreGraphics) {
            return .coreGraphics
        } else {
            return .default
        }
        #else
        if StoryContext.supportsType(.coreGraphics) {
            return .coreGraphics
        } else {
            return .default
        }
        #endif
    }
    /**
     Create and returns a new context with the given type. You must check
     whether the contextType is supported by calling +[StoryContext supportsType:] before.
     */
    class func contextWithType(_ contextType: StoryContextType, options: [AnyHashable: Any]?) -> StoryContext? {
        switch contextType {
        case .auto:
            return StoryContext.contextWithType(StoryContext.suggestedContextType(), options: options)
        case .metal:
            var device = options?[StoryContextOptionsMTLDeviceKey] as? MTLDevice
            if device == nil {
                device = MTLCreateSystemDefaultDevice()
            }
            return StoryContext(mtlDevice: device!)
        case .coreGraphics:
            let context = options?[StoryContextOptionsCGContextKey]
            if context == nil {
                fatalError("MissingCGContext : StoryContextTypeCoreGraphics needs to have a CGContext attached to the StoryContextOptionsCGContextKey in the options")
            }
            return StoryContext(cgContextRef: context as! CGContext)
        case .cpu:
            return StoryContext(softwareRenderer: true)
        case .default:
            return StoryContext(softwareRenderer: false)
        }
    }
    
}
