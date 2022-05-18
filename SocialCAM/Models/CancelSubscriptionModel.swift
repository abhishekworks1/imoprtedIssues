import Foundation 
import ObjectMapper 

class CancelSubscriptionModel: Mappable { 

	var status: String? 
	var code: NSNumber? 
	var message: String? 
	var result: ResultCancelSub?

	required init?(map: Map){ 
	} 

	func mapping(map: Map) {
		status <- map["status"] 
		code <- map["code"] 
		message <- map["message"] 
		result <- map["result"] 
	}
} 

class ResultCancelSub: Mappable {

	var userSubscription: [UserSubscriptionCancel]?

	required init?(map: Map){ 
	} 

	func mapping(map: Map) {
		userSubscription <- map["userSubscription"] 
	}
} 

class UserSubscriptionCancel: Mappable {
	var Id: String? 
	var updatedAt: String? 
	var createdAt: String? 
	var userId: String? 
	var subscriptionId: String? 
	var amount: NSNumber? 
	var startDate: String? 
	var productId: String? 
	var inAppResponse: String? 
	var inAppTransactionId: String? 
	var endDate: String? 
	var V: NSNumber? 
	var isDeleted: Bool? 
	var isActive: Bool? 
	var created: String? 
	var trialDaysLeft: NSNumber? 
	var allowFullAccess: Bool? 
	var isExtended: Bool? 
	var isDowngraded: Bool? 
	var isRenewable: Bool? 
	var inAppMode: String? 
	var transactions: [Transactions]? 
	var platformType: String? 
	var subscriptionType: String? 

	required init?(map: Map){ 
	} 

	func mapping(map: Map) {
		Id <- map["_id"] 
		updatedAt <- map["updatedAt"] 
		createdAt <- map["createdAt"] 
		userId <- map["userId"] 
		subscriptionId <- map["subscriptionId"] 
		amount <- map["amount"] 
		startDate <- map["startDate"] 
		productId <- map["productId"] 
		inAppResponse <- map["inAppResponse"] 
		inAppTransactionId <- map["inAppTransactionId"] 
		endDate <- map["endDate"] 
		V <- map["__v"] 
		isDeleted <- map["isDeleted"] 
		isActive <- map["isActive"] 
		created <- map["created"] 
		trialDaysLeft <- map["trialDaysLeft"] 
		allowFullAccess <- map["allowFullAccess"] 
		isExtended <- map["isExtended"] 
		isDowngraded <- map["isDowngraded"] 
		isRenewable <- map["isRenewable"] 
		inAppMode <- map["inAppMode"] 
		transactions <- map["transactions"] 
		platformType <- map["platformType"] 
		subscriptionType <- map["subscriptionType"] 
	}
} 

class Transactions: Mappable { 

	var environment: String? 
	var offerType: NSNumber? 
	var signedDate: NSNumber? 
	var inAppOwnershipType: String? 
	var type: String? 
	var quantity: NSNumber? 
	var expiresDate: NSNumber? 
	var originalPurchaseDate: NSNumber? 
	var purchaseDate: NSNumber? 
	var subscriptionGroupIdentifier: String? 
	var productId: String? 
	var bundleId: String? 
	var webOrderLineItemId: String? 
	var originalTransactionId: String? 
	var transactionId: String? 

	required init?(map: Map){ 
	} 

	func mapping(map: Map) {
		environment <- map["environment"] 
		offerType <- map["offerType"] 
		signedDate <- map["signedDate"] 
		inAppOwnershipType <- map["inAppOwnershipType"] 
		type <- map["type"] 
		quantity <- map["quantity"] 
		expiresDate <- map["expiresDate"] 
		originalPurchaseDate <- map["originalPurchaseDate"] 
		purchaseDate <- map["purchaseDate"] 
		subscriptionGroupIdentifier <- map["subscriptionGroupIdentifier"] 
		productId <- map["productId"] 
		bundleId <- map["bundleId"] 
		webOrderLineItemId <- map["webOrderLineItemId"] 
		originalTransactionId <- map["originalTransactionId"] 
		transactionId <- map["transactionId"] 
	}
} 

