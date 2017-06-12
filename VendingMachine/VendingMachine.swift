//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Frederick Balagadde on 6/10/17.
//  Copyright © 2017 Treehouse Island, Inc. All rights reserved.
//

import Foundation
import UIKit

enum VendingSelection: String
{
    case soda
    case dietSoda
    case chips
    case cookie
    case sandwich
    case wrap
    case candyBar
    case popTart
    case water
    case fruitJuice
    case sportsDrink
    case gum
    
    func icon() -> UIImage
    {
        /*
        switch self {
        case .soda:
            return UIImage(named: "soda")
        default:
        }
        */
        
        
        if let image = UIImage(named: self.rawValue)
        {
            return image
        } else
        {
            return #imageLiteral(resourceName: "default")
            
            //UIImage(named: "default")!
        }
        
        //return UIImage(named: self.RawValue)
    }
}

protocol VendingItem
{
    var price: Double { get }
    var quantity: Int { get set }
}

protocol VendingMachine
{
    var selection: [VendingSelection] { get }
    var inventory: [VendingSelection: VendingItem] { get set }
    var amountDeposited: Double { get set }
    
    init(inventory: [VendingSelection: VendingItem])
    func vend(selection: VendingSelection, quantity: Int) throws
    func deposit(_ amount: Double)
    func item(forSelection selection: VendingSelection) -> VendingItem?
}


struct Item: VendingItem
{
    let price: Double
    var quantity: Int
}

enum InventoryError : Error
{
    case invalidResource
    case conversionFailure
    case invalidSelection
}

class PListConverter
{
    static func dictionary(fromFile name: String, ofType type: String) throws -> [String: AnyObject]
    {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else
        {
            throw InventoryError.invalidResource
        }
        
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else  //Conditional downcast operator
        {
            throw InventoryError.conversionFailure
        }
        
        return dictionary
    }
}

class InventoryUnarchiver
{
    static func vendingInventory(fromDictionary dictionary: [String: AnyObject]) throws -> [VendingSelection : VendingItem]
    {
        var inventory: [VendingSelection: VendingItem] = [:]
        
        for (key, value) in dictionary
        {
            if let itemDictionary = value as? [String: Any], let price = itemDictionary["price"] as? Double, let quantity = itemDictionary["quantity"] as? Int
            {
                let item = Item(price: price, quantity: quantity)
                
                guard let selection = VendingSelection(rawValue: key) else
                {
                    throw InventoryError.invalidSelection
                }
                
                inventory.updateValue(item, forKey: selection)
            }
            
        }
        
        return inventory
    }
}

/*
for employee in employees
{
    if employee is HourlyEmployee
    {
        print("Hourly")
        let hourlyEmployee = employee as! HourlyEmployee //Forced casting, forced downcast operator
        hourlyEmployee.payWages(for: 10.00)
       
        //Alternatively1
        if let hourlyEmployee = employee as? HourlyEmployee
        {
            hourlyEmployee.payWages(for: 10.00)
        }
 
        //Alternatively2
        let hourlyEmployee = employee as? HourlyEmployee    //Conditional casting returns an optionsl
        if let hourlyEmployee2 = hourlyEmployee
        {
            hourlyEmployee2.payWages(forL 10.00)
        }
    }
 
    if employee is SalariedEmployee
    {
        print("Salaried")
        let salariedEmployee = employee as! SalariedEmployee
        hourlyEmployee.paySalary()
    }
}

 */


enum VendingMachineError: Error
{
    case invalidSelection
    case outOfStock
    case insufficientFunds(required: Double)
}

class FoodVendingMachine: VendingMachine
{
    let selection: [VendingSelection] = [.soda, .dietSoda, .chips, .cookie, .sandwich, .wrap, .candyBar, .popTart, .water, .fruitJuice, .sportsDrink, .gum]
    var inventory: [VendingSelection : VendingItem]
    var amountDeposited: Double = 10.0
    
    required init(inventory: [VendingSelection : VendingItem])
    {
        self.inventory = inventory
        //try PListConverter.dictionary(fromFile: "vendingInventory", ofType: "plist")
        
        // PListConverter.dictionary(fromFile: "vendingInventory", ofType: "plist")
    }
    
    func vend(selection: VendingSelection, quantity: Int)  throws
    {
        guard var item = inventory[selection] else
        {
            throw VendingMachineError.invalidSelection
        }
        
        guard item.quantity >= quantity else
        {
            throw VendingMachineError.outOfStock
        }
        
        let totalPrice = item.price * Double(quantity)
        
        if amountDeposited >= totalPrice
        {
            amountDeposited -= totalPrice
            
            item.quantity -= quantity
            
            inventory.updateValue(item, forKey: selection)
        } else
        {
            let amountRequired = totalPrice - amountDeposited
            throw VendingMachineError.insufficientFunds(required: amountRequired)
        }
    }
    
    func deposit(_ amount: Double)
    {
        amountDeposited += amount
    }
    
    func item(forSelection selection: VendingSelection) -> VendingItem? {
        return inventory[selection]
    }
}

//PList -> Dictionary, Dictionary -> PList






























