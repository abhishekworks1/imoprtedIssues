//
//  PhoneContact.swift
//  SocialCAM
//
//

import Foundation
import ContactsUI


//{
//  "content": "Hi! Dummy message text for design http://alpha.quickcam.app/sagarpersonal2/txt/cid=621dff2f0c895749b92af93d",
//  "invitedFrom":"mobile",
//  "contactListIds": [
//    "621dff2f0c895749b92af93d"
//  ]
//}
struct InviteDetails:Codable{
    var content: String = ""
    var invitedFrom: String = ""
    var subject: String = ""
    var contactListIds: [String] = [String]()
    
    init(content:String,subject:String = "",invitedFrom:String,contactListIds:[String]) {
        self.contactListIds = contactListIds
        self.content = content
        self.subject = subject
        self.invitedFrom = invitedFrom
        
    }
    
}
struct InviteEmailDetails:Codable{
    var emailTitle: String = ""
    var emailMessage: String = ""
    var contactListIds: [String] = [String]()
    
    init(emailTitle:String,emailMessage:String,contactListIds:[String]) {
        self.contactListIds = contactListIds
        self.emailTitle = emailTitle
        self.emailMessage = emailMessage
    }
    
}

struct ContactDetails:Codable{
    var name: String?
    var email: String?
    var mobile: String?
    var contactSource: String?
    var trackReferral: Bool = false
    
    init(contact:PhoneContact,trackRefferel:Bool = false) {
        self.name = contact.name ?? ""
        if contact.email.count > 0{
            self.email = contact.email.first ?? ""
        }
        if contact.phoneNumber.count > 0{
            self.mobile = contact.phoneNumber.first ?? ""
        }
        self.trackReferral = trackRefferel
        self.contactSource = "mobile"
    }
    
}

enum ContactsFilter {
        case none
        case mail
        case message
    }
class PhoneContact: NSObject {

    var name: String?
    var avatarData: Data?
    var phoneNumber: [String] = [String]()
    var email: [String] = [String]()
    var isSelected: Bool = false
    var isInvited = false

    init(contact: CNContact) {
        name        = contact.givenName + " " + contact.familyName
        avatarData  = contact.thumbnailImageData
        for phone in contact.phoneNumbers {
            phoneNumber.append(phone.value.stringValue)
        }
        for mail in contact.emailAddresses {
            email.append(mail.value as String)
        }
    }

    override init() {
        super.init()
    }
    
    class func getContacts(filter: ContactsFilter = .none) -> [CNContact] { //  ContactsFilter is Enum find it below

            let contactStore = CNContactStore()
            let keysToFetch = [
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                CNContactPhoneNumbersKey,
                CNContactEmailAddressesKey,
                CNContactThumbnailImageDataKey] as [Any]

            var allContainers: [CNContainer] = []
            do {
                allContainers = try contactStore.containers(matching: nil)
            } catch {
                print("Error fetching containers")
            }

            var results: [CNContact] = []

            for container in allContainers {
                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

                do {
                    let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                    results.append(contentsOf: containerResults)
                } catch {
                    print("Error fetching containers")
                }
            }
            return results
        }
    
}
