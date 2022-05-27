//
//  DemoUtils.swift
//  Keyboard
//
//  Created by Shilo White on 4/17/21.
//  Copyright © 2021 Daniel Saidi. All rights reserved.
//

import Foundation
import KeyboardKit

class KeyboardInputSetProviderData {
    public let language: String
    public let alphabeticInputSetRows: [KeyboardInputRow]
    public let numericInputSetRows: [KeyboardInputRow]
    public let symbolicInputSetRows: [KeyboardInputRow]
    
    init(keyboardInputSetProvider: KeyboardInputSetProvider, keyboardContext: KeyboardContext?) {
        language = ((keyboardInputSetProvider as? LocalizedService)?.localeKey ?? keyboardContext?.locale.languageCode ?? "nil")!
        alphabeticInputSetRows = keyboardInputSetProvider.alphabeticInputSet().rows
        numericInputSetRows = keyboardInputSetProvider.numericInputSet().rows
        symbolicInputSetRows = keyboardInputSetProvider.symbolicInputSet().rows
    }
    
    static func providersData(providers: [String: KeyboardInputSetProvider]?) -> [String: KeyboardInputSetProviderData]? {
        var providersData = [String: KeyboardInputSetProviderData]()
        
        if (providers != nil) {
            for provider in providers! {
                providersData[provider.key] = KeyboardInputSetProviderData(keyboardInputSetProvider: provider.value, keyboardContext: nil)
            }
        }
        
        return providersData.count > 0 ? providersData : nil
    }
    
    static func printKeyboardInputSets(for keyboardInputSetProvider: KeyboardInputSetProvider, keyboardContext: KeyboardContext?) {
        print("==================================")
        print("==== START KEYOARD INPUT SETS ====")
        print("==================================")
        
        var providers: [String: KeyboardInputSetProviderData]? = KeyboardInputSetProviderData.providersData(providers: (keyboardInputSetProvider as? StandardKeyboardInputSetProvider)?.providerDictionary.dictionary)
        
        if (providers == nil && keyboardContext != nil) {
            print("[Error] Failed to get providers. Second attempt...")
            
            let curLocale = keyboardContext!.locale
            providers = [String: KeyboardInputSetProviderData]()
            
            for locale in KeyboardLocale.allCases {
                keyboardContext!.locale = locale.locale
                providers![locale.rawValue] = KeyboardInputSetProviderData(keyboardInputSetProvider: keyboardInputSetProvider, keyboardContext: keyboardContext)
            }
            
            keyboardContext!.locale = curLocale
        }
        
        if (providers != nil) {
            for obj in providers! {
                let provider = obj.value
                print("\n\n==== \(String(describing: provider.language)) ====")
                
                print("\n== Alphabetic (\(String(describing: provider.language)))")
                for row in provider.alphabeticInputSetRows {
                    let chars = keyboardInputRowChars(for:row)
                    print(chars)
                }
                
                print("\n== Numeric (\(String(describing: provider.language)))")
                for row in provider.numericInputSetRows {
                    let chars = keyboardInputRowChars(for:row)
                    print(chars)
                }
                
                print("\n== Symbolic (\(String(describing: provider.language)))")
                for row in provider.symbolicInputSetRows {
                    let chars = keyboardInputRowChars(for:row)
                    print(chars)
                }
            }
        } else {
            print("[Error] Failed to get providers.")
        }
        
        print("\n\n==================================")
        print("===== END KEYOARD INPUT SETS =====")
        print("==================================")
    }
    
    static private func keyboardInputRowChars(for row: KeyboardInputRow) -> String {
        var chars = ""
        for key in row {
            chars += key.neutral
        }
        return chars
    }
}

class SecondaryCalloutActionProviderData {
    public var language: String
    public let secondaryCalloutActions: [String: String]?
    
    init(secondaryCalloutActionProvider: SecondaryCalloutActionProvider, keyboardContext: KeyboardContext?) {
        language = (keyboardContext?.locale.languageCode ?? "nil")!
        
        var actions = [String: String]()
        let ascii = String(Array(0...255).map { Character(Unicode.Scalar($0)) })
        for char in ascii {
            let key = String(char)
            
            var value = ""
            if (secondaryCalloutActionProvider is BaseSecondaryCalloutActionProvider) {
                value = (secondaryCalloutActionProvider as! BaseSecondaryCalloutActionProvider).secondaryCalloutActionString(for: key)
            } else {
                let calloutActions = secondaryCalloutActionProvider.secondaryCalloutActions(for: .character(key))
                value = SecondaryCalloutActionProviderData.charactersForSecondaryCalloutActions(actions: calloutActions)
            }
            if (value.count > 0) {
                actions[key] = value
            }
        }
        
        secondaryCalloutActions = actions.count > 0 ? actions : nil
    }
    
    static func providersData(providers: [String: SecondaryCalloutActionProvider]?) -> [String: SecondaryCalloutActionProviderData]? {
        var providersData = [String: SecondaryCalloutActionProviderData]()
        
        if (providers != nil) {
            for provider in providers! {
                let providerData = SecondaryCalloutActionProviderData(secondaryCalloutActionProvider: provider.value, keyboardContext: nil)
                if (providerData.language == "nil") {
                    providerData.language = provider.key
                }
                providersData[provider.key] = providerData
            }
        }
        
        return providersData.count > 0 ? providersData : nil
    }

    static func printSecondaryCallouts(for secondaryCalloutActionProvider: SecondaryCalloutActionProvider, keyboardContext: KeyboardContext?) {
        print("==================================")
        print("==== START SECONDARY CALLOUTS ====")
        print("==================================")
        
        var providers: [String: SecondaryCalloutActionProviderData]? = SecondaryCalloutActionProviderData.providersData(providers: (secondaryCalloutActionProvider as? StandardSecondaryCalloutActionProvider)?.providerDictionary.dictionary)
        
        if (providers == nil && keyboardContext != nil) {
            print("[Error] Failed to get providers. Second attempt...")
            
            let curLocale = keyboardContext!.locale
            providers = [String: SecondaryCalloutActionProviderData]()
            
            for locale in KeyboardLocale.allCases {
                keyboardContext!.locale = locale.locale
                providers![locale.rawValue] = SecondaryCalloutActionProviderData(secondaryCalloutActionProvider: secondaryCalloutActionProvider, keyboardContext: keyboardContext)
            }
            
            keyboardContext!.locale = curLocale
        }
        
        if (providers != nil) {
            for obj in providers! {
                let provider = obj.value
                print("\n\n==== Actions (\(String(describing: provider.language))) ====")
                let actions = provider.secondaryCalloutActions
                if (actions != nil) {
                    for action in provider.secondaryCalloutActions! {
                        if (action.value.count > 0) {
                            //print("\(action.key)=\(action.value)")
                            print("case \"\(action.key)\": return \"\(action.value)\"")
                        }
                    }
                } else {
                    print("nil")
                }
            }
        } else {
            print("[Error] Failed to get providers.")
        }
        
        print("\n\n==================================")
        print("===== END SECONDARY CALLOUTS =====")
        print("==================================")
    }
    
    static private func charactersForSecondaryCalloutActions(actions: [KeyboardAction]) -> String {
        var characters = ""
        
        if (actions.count > 0) {
            for action in actions {
                switch action {
                case .character(let char): characters += char
                default:
                    continue
                }
            }
        }
        
        return characters
    }
}
