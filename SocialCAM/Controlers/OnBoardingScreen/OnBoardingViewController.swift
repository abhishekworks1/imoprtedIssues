//
//  OnBoardingViewController.swift
//  SocialCAM
//
//  Created by Siddharth on 09/06/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class QuickStartCategoryContent: Codable, Equatable {
    static func == (lhs: QuickStartCategoryContent, rhs: QuickStartCategoryContent) -> Bool {
        return lhs._id == rhs._id
    }
    
    var _id: String?
    var categoryId: String?
    var title: String?
    var video: String?
    var cta_text: String?
    var cta_link: String?
    var status: String?
    var __v: Int?
    var template: String?
    var region: String?
    var sequence_no: Int?
    var createdAt: String?
    var updatedAt: String?
    var isread: Bool?
    var content: String?
}

class QuickStartCategory: Codable, Equatable {
    static func == (lhs: QuickStartCategory, rhs: QuickStartCategory) -> Bool {
        return lhs._id == rhs._id
    }
    
    var _id: String?
    var catId: String?
    var label: String?
    var region: String?
    var template: String?
    var completionMsg: String?
    var ordinal: String?
    var __v: Int?
    var created: String?
    var Items: [QuickStartCategoryContent]?
}

enum QuickStartSocialMediaOption: Int {
    case tiktok
    case instagram
    case youtube
    case facebook
    case twitter
    case linkedin
}

protocol QuickStartOptionable {
    var title: String { get }
    var description: String { get }
    var isLastStep: Bool { get }
    var isFirstStep: Bool { get }
    var hideTryNowButton: Bool { get }
    var rawValue: Int { get }
    var apiKey: String { get }
}
extension QuickStartOptionable {
    var hideTryNowButton: Bool {
        return true
    }

}
enum QuickStartOption: Int, CaseIterable {
    
    case createContent = 0
    case mobileDashboard
    case makeMoney
    
    var titleText: String {
        switch self {
        case .createContent:
            return "Create Engaging Content"
        case .mobileDashboard:
            return "Mobile Dashboard"
        case .makeMoney:
            return "Make Money Referring QuickCam"
        }
    }
    
    func option(for rawValue: Int) -> QuickStartOptionable? {
        switch self {
        case .createContent:
            return CreateContentOption(rawValue: rawValue)
        case .mobileDashboard:
            return MobileDashboardOption(rawValue: rawValue)
        case .makeMoney:
            return MakeMoneyOption(rawValue: rawValue)
        }
    }
    
    enum CreateContentOption: Int, CaseIterable, QuickStartOptionable {
        var apiKey: String {
            switch self {
            case .quickCamCamera:
                return "ios_createcontent_quickCamCamera"
            case .fastSlowEditor:
                return "ios_createcontent_fastSlowRecording"
            case .quickieVideoEditor:
                return "ios_createcontent_quickieVideoEditor"
            case .pic2Art:
                return "ios_createcontent_pic2Art"
            case .bitmojis:
                return "ios_createcontent_bitmojis"
            case .socialMediaSharing:
                return "ios_createcontent_socialMediaSharing"
            case .yourGoal:
                return "ios_createcontent_yourGoal"
            }
        }
        
        var title: String {
            switch self {
            case .quickCamCamera:
                return "QuickCam Camera"
            case .fastSlowEditor:
                return "Fast & Slow Motion Recording"
            case .quickieVideoEditor:
                return "Quickie Video Editor"
            case .pic2Art:
                return "Pic2Art"
            case .bitmojis:
                return "Bitmojis"
            case .socialMediaSharing:
                return "Social Media Sharing"
            case .yourGoal:
                return "Your Goal"
            }
        }
        
        var description: String {
            switch self {
            case .quickCamCamera:
                return """
<ul>
<li class="p1">Fast and Slow Motion speeds depends on subscription level.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Free: 3x fast motion (No slow motion)</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Basic: -3x slow motion up to 3x fast motion</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Advanced: -4x slow motion up to 4x fast motion</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Premium: -5x slow motion up to 5x fast motion</li>
</ul>
"""
            case .fastSlowEditor:
                return """
<ul>
<li class="p1">Simply touch and hold the record button, then move your finger to the right to record in fast motion, and move your finger to the left for slow motion. Return to the middle for normal speed.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Move your finger from bottom to top to zoom in and back down to zoom out while using the fast/slow motion real-time recording.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">When you lift up your finger, your video will begin playing back immediately in the Quickie Video Editor.</li>
</ul>
"""
            case .quickieVideoEditor:
                return """
<ul>
<li class="p1">Quickly edit your video and share on social media.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Crop, trim and cut your videos.</li>
</ul>
"""
            case .bitmojis:
                return """
<ul>
<li class="p1">
<p class="p1">Connect your Snapchat account with your Bitmojis to QuickCam to integrate your bitmojis into your video quickies and Pic2Art.</p>
</li>
</ul>
"""
            case .socialMediaSharing:
                return """
<ul>
<li class="p1">Share your video quickies on TikTok, Instagram, Snapchat, Facebook, YouTube, Twitter and more.</li>
</ul>
<p class="p2">&nbsp;</p>
<ul>
<li class="p1">Share your video quickies on local social media platforms like Chingari and Takatak.</li>
</ul>
"""
            case .pic2Art:
                return """
<ul>
<li class="p1">Turn your ordinary photos into beautiful digital art that you&rsquo;ll want to print and hang on your wall!</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">44 filters to choose from to create unique Pic2Art every time.</li>
</ul>
"""
            case .yourGoal:
                return """
<ul>
<li class="p1">Your first goal is to learn how to create fun and engaging content. You can create Quickie video and also take photos that you can convert into beautiful Pic2Art digital images.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">You can edit your existing videos in QuickCam's Quickie Video Editor and post them in your favorite social media platform that QuickCam supports. Or you can create new videos with QuickCam's patented fast &amp; slow motion special effects in real-time. You can edit your new videos in QuickCam's Quickie Video Editor and post them in your favorite social media platform that QuickCam supports.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">When you use Pic2Art, you can take pictures of ordinary objects and convert them into art so beautiful you can hang on your wall and proudly share with your friends and followers on the social media platform that QuickCam supports.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">We suggest that you share your content with all the social media platforms supported by QuickCam.</li>
</ul>
"""
            }
        }
        
        var isLastStep: Bool {
            return self == .yourGoal
        }
        
        var isFirstStep: Bool {
            return self == .quickCamCamera
        }

        case quickCamCamera = 0
        case fastSlowEditor
        case quickieVideoEditor
        case pic2Art
        case bitmojis
        case socialMediaSharing
        case yourGoal
    }

    enum MobileDashboardOption: Int, CaseIterable, QuickStartOptionable {
        
        var apiKey: String {
            switch self {
            case .notifications:
                return "ios_mobiledashboard_notifications"
            case .howItWorks:
                return "ios_mobiledashboard_howItWorks"
            case .cameraSettings:
                return "ios_mobiledashboard_cameraSettings"
            case .subscriptions:
                return "ios_mobiledashboard_subscriptions"
            case .checkForUpdates:
                return "ios_mobiledashboard_checkForUpdates"
            case .badges:
                return "ios_mobiledashboard_badges"
            }
        }
        
        var title: String {
            switch self {
            case .notifications:
                return "Notifications"
            case .howItWorks:
                return "How it Works"
            case .cameraSettings:
                return "Camera Settings"
            case .subscriptions:
                return "Subscription"
            case .checkForUpdates:
                return "Check Updates"
            case .badges:
                return "Badges"
            }
        }
        
        var description: String {
            switch self {
            case .notifications:
                return """
<ul>
<li class="p1">Get a notification whenever one of your contacts signs up as a referral.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Get a notification whenever one of your referrals subscribes.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Get a notification whenever one of the channels you&rsquo;re following earns a new badge!</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Get a daily notification of the summary of the day&rsquo;s referral activity.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Set your notifications to receive only the ones you want.</li>
</ul>
"""
            case .howItWorks:
                return """
<ul>
<li class="p1">
<p class="p1">Get all of the tutorials videos in one location in the Tutorials.</p>
</li>
</ul>
"""
            case .cameraSettings:
                return """
<ul>
<li class="p1">Change the camera settings to unleash your style and optimize your creativity.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Camera settings options available are based on your subscription level.</li>
</ul>
"""
            case .subscriptions:
                return """
<ul>
<li class="p1">7-Day Premium Free Trial</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Free User mode afterward for non-subscribers</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">"Early-Bird Special" Subscription Price - During Pre-Launch</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Android
<ul style="list-style-type: disc;">
<li class="p1">Basic -&nbsp; $0.99/month</li>
<li class="p1">Advanced -&nbsp; $1.99/month</li>
<li class="p1">Premium -&nbsp; $3.99/month</li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">iPhone
<ul style="list-style-type: disc;">
<li class="p1">Basic -&nbsp; $1.99/month</li>
<li class="p1">Advanced -&nbsp; $2.99/month</li>
<li class="p1">Premium -&nbsp; $4.99/month</li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Regular Price - to be announced after Early Bird Special</li>
</ul>
"""
            case .checkForUpdates:
                return """
<ul>
<li class="p1">We periodically update the app to include additional features and bug fixes.</li>
</ul>
"""
            case .badges:
                return """
<ul>
<li style="font-weight: 400;" aria-level="2"><span style="font-weight: 400;">Founding Members Badge - Earned by all users signing up now until Dec. 31, 2022</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2"><span style="font-weight: 400;">Prelaunch Badge&nbsp; - Earned by all users signing up now during Prelaunch.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2">Premium Subscription Badge - Earned by subscribing to the Premium plan.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2">Advanced Subscription Badge - Earned by subscribing to the Advanced plan.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2">Basic Subscription Badge - Earned by subscribing to the Basic plan.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2">Free User Badge - Designated for non-subscribers.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2"><span style="font-weight: 400;">Day Subcribed Badge - Earned when you subscribe during the 7-Day Premium Free Trial.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li data-sourcepos="13:1-16:0">
<p data-sourcepos="13:4-14:71">Inviter Badge - Earned by inviting your contacts who join and subscribe.</p>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2">Social Connection Badge - Earned when you connect your social media accounts.</li>
</ul>
"""
            }
        }
        
        var isLastStep: Bool {
            return self == .checkForUpdates
        }
        
        var isFirstStep: Bool {
            return self == .notifications
        }
        
        case notifications = 0
        case howItWorks
        case cameraSettings
        case subscriptions
        case badges
        case checkForUpdates
    }

    enum MakeMoneyOption: Int, CaseIterable, QuickStartOptionable {
        var apiKey: String {
            switch self {
            case .referralCommissionProgram:
                return "ios_makemoney_referralCommissionProgram"
            case .referralWizard:
                return "ios_makemoney_referralWizard"
            case .contactManagerTools:
                return "ios_makemoney_contactManagerTools"
            case .potentialCalculator:
                return "ios_makemoney_potentialCalculator"
            case .fundraising:
                return "ios_makemoney_fundraising"
            case .yourGoal:
                return "ios_makemoney_yourGoal"
            case .quickCam:
                return "ios_makemoney_quickcam"
            }
        }
        
        var title: String {
            switch self {
            case .referralCommissionProgram:
                return "Referral Commissions Program"
            case .referralWizard:
                return "Invite Wizard"
            case .contactManagerTools:
                return "Contact Management Tools"
            case .fundraising:
                return "Great for Fundraising"
            case .yourGoal:
                return "Your Goal"
            case .potentialCalculator:
                return "Income Goal Calculator"
            case .quickCam:
                return "Who is QuickCam for?"
            }
            
        }
        
        var description: String {
            switch self {
            case .referralCommissionProgram:
                return """
<ol>
    <li style="font-weight: bold;">
        <p><strong>2-Level Referral Revenue Share</strong></p>
        <ul style="font-weight: initial; list-style-type: disc;">
            <li>
                <p>When any of your referrals download QuickCam and subscribe, 50% of the subscription revenues is paid to you for the first 2 months. Thereafter, 25% is paid to you and 25% is paid to your referring channel.</p>
            </li>
            <li>
                <p>When your referrals also refer to their contacts and those contacts sign up and subscribe, your referrals earn 25% and you&apos;ll earn a matching bonus of 25% on the 3rd month and thereafter.</p>
            </li>
        </ul>
    </li>
    <li style="font-weight: bold;">
        <p><strong>How can I earn money?</strong></p>
        <ul style="font-weight: initial; list-style-type: disc;">
            <li>
                <p>Share your videos with your referral link in your private snaps, direct messages, social media posts, email and text messages.</p>
            </li>
            <li>
                <p>Share your QR code to your referral link in person and in print. For example, business cards and promotional material..</p>
            </li>
            <li>
                <p>Let&apos;s say your contacts click on your referral link and sign up. When they confirm you as their referring channel, you&apos;ll get a notification letting you know you have new referrals.</p>
            </li>
            <li>
                <p>When they subscribe, you begin earning ongoing passive monthly residual income!!</p>
            </li>
        </ul>
    </li>
    <li style="font-weight: bold;">
        <p><strong>How much money can I earn?</strong></p>
        <ul style="font-weight: initial; list-style-type: disc;">
            <li>
                <p>It depends on you and those you share QuickCam with.</p>
            </li>
            <li>
                <p>We&apos;ve provided a Income Goal Calculator so you can set your goals and find out.</p>
            </li>
            <li>
                <p>Use the special effects to create fun and engaging videos to share online to get more referrals. The more referrals you have who subscribe, the more money you&apos;ll make.</p>
            </li>
            <li>
                <p>Use the Mobile Dashboard TextShare, EmailShare, SocialShare and QRCodeShare to get more referrals.</p>
            </li>
            <li>
                <p>Login frequently to the QuickCam Business Dashboard to keep track of how much you&apos;re making.</p>
            </li>
        </ul>
    </li>
</ol>
"""
            case .referralWizard:
                return """
<p><span style="font-weight: 400;">The following are the ways you can refer QuickCam to your friends, family, followers, neighbors, co-workers, church members, club members, non-profit supporters and everyone you know.</span></p>
<p>&nbsp;</p>
<ul>
<li aria-level="2"><strong>TextShare&trade;</strong><span style="font-weight: 400;">&nbsp;</span>
<ul style="list-style-type: disc;">
<li aria-level="2"><span style="font-weight: 400;">Use TextShare to invite your contacts by sending them a text with your unique referral link.</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="list-style-type: none;">
<ul style="list-style-type: disc;">
<li aria-level="2"><span style="font-weight: 400;">Use TextShare as the surest and fastest way to share the QuickCam opportunity and grow your potential income because text messages are more likely to be opened than an email.</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="list-style-type: none;">
<ul style="list-style-type: disc;">
<li aria-level="2"><span style="font-weight: 400;">After you send your invites, each time you open Contact Inviter, thereafter, you&rsquo;ll be able to track the contacts you invited and see when the recipients have opened, signed up and subscribed.</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li aria-level="2"><strong>EmailShare&trade;</strong>
<ul style="list-style-type: disc;">
<li aria-level="2"><span style="font-weight: 400;">Use the EmailShare to invite your contacts by sending them an email with your unique referral link.</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="list-style-type: none;">
<ul style="list-style-type: disc;">
<li aria-level="2"><span style="font-weight: 400;">You&rsquo;ll be able to connect your Gmail and Outlook email accounts to use the automated EmailShare to invite all of your contacts in one click.</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="list-style-type: none;">
<ul style="list-style-type: disc;">
<li aria-level="2"><span style="font-weight: 400;">You&rsquo;ll be able to track the contacts you emailed and see when the recipients have opened, signed up and subscribed.</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li aria-level="2"><strong>SocialShare&trade;&nbsp;</strong>
<ul style="list-style-type: disc;">
<li aria-level="2"><span style="font-weight: 400;">Use SocialShare to invite your social media followers by posting your unique referral link to your social media newsfeed.</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="list-style-type: none;">
<ul style="list-style-type: disc;">
<li aria-level="2"><span style="font-weight: 400;">For influencers with a large following, SocialShare is a way to get wide exposure to their referral link.</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="list-style-type: none;">
<ul style="list-style-type: disc;">
<li aria-level="2"><span style="font-weight: 400;">You can post to the following social media platforms that SocialShare supports: Facebook, Instagram, Snapchat, Twitter, Whatsapp, Messenger and more.&nbsp;</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li aria-level="2"><strong>QRCodeShare&trade;</strong></li>
</ul>
<ul>
<li style="list-style-type: none;">
<ul style="list-style-type: disc;">
<li style="font-weight: 400;" aria-level="3"><span style="font-weight: 400;">Use QRCodeShare to invite your in-person contacts by sharing your QR Code.</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="list-style-type: none;">
<ul style="list-style-type: disc;">
<li style="font-weight: 400;" aria-level="3"><span style="font-weight: 400;">When they scan your QR Code and sign up, you&rsquo;ll receive credit as their referring channel.</span></li>
</ul>
</li>
</ul>
"""
            case .contactManagerTools:
                return """
<ul>
<li aria-level="2"><strong>Business Dashboard is:</strong>
<ul style="list-style-type: disc;">
<li><span style="font-weight: 400;">currently available for free during prelaunch</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="list-style-type: none;">
<ul style="list-style-type: disc;">
<li><span style="font-weight: 400;">for those who want to make money online.&nbsp;</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="list-style-type: none;">
<ul style="list-style-type: disc;">
<li><span style="font-weight: 400;">a management tool to track your referrals, earnings, payout and more.</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="list-style-type: none;">
<ul style="list-style-type: disc;">
<li><span style="font-weight: 400;">accessible directly from the QuickCam camera app.</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="list-style-type: none;">
<ul style="list-style-type: disc;">
<li><span style="font-weight: 400;">a separate subscription product from the QuickCam camera app.&nbsp;</span></li>
</ul>
</li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="list-style-type: none;">
<ul style="list-style-type: disc;">
<li><span style="font-weight: 400;">to be available with paid subscriptions and referral commissions (to be announced).<br /></span></li>
</ul>
</li>
<li aria-level="2"><strong>Contact Inviter</strong>
<ul style="list-style-type: disc;">
<li><span style="font-weight: 400;">Invite and track your referrals, see who has signed up and who&rsquo;s subscribing.</span></li>
</ul>
</li>
</ul>
"""
            case .fundraising:
                return """
<ul>
<li class="p1">Raise funds for clubs, groups or non-profits that you support by sharing your referral link.</li>
</ul>
<p>&nbsp;</p>
<ul>
<li class="p1">Clubs, groups or non-profits can get their members to join and pledge a portion of their earnings when they refer Quickcam.</li>
</ul>
"""
            case .yourGoal:
                return """
<p dir="auto" data-sourcepos="7:1-7:103">Use TextShare as the surest and fastest way to share the QuickCam opportunity and grow your potential income because text messages are more likely to be opened than an email.</p>
<p dir="auto" data-sourcepos="9:1-9:196">&nbsp;</p>
<p dir="auto" data-sourcepos="9:1-9:196">Your first goal is to meet your expenses because everything after that is pure profit. When 2 of your referrals subscribe at the same level or higher than your subscription, your expenses are met.</p>
<p dir="auto" data-sourcepos="9:1-9:196">&nbsp;</p>
<p dir="auto" data-sourcepos="11:1-11:152">Your second goal is start making a profit by sharing the QuickCam opportunity to more of your friends, family members and followers on social media.</p>
<p dir="auto" data-sourcepos="13:1-13:37">&nbsp;</p>
"""            case .potentialCalculator:
                return """
<ul>
<li style="font-weight: 400;" aria-level="2"><span style="font-weight: 400;">You can play with the Income Goal Calculator to see your potential monthly income.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2"><span style="font-weight: 400;">Enter the number of level 1 personal referrals and level 2 referral into the calculator and the subscription variables.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2"><span style="font-weight: 400;">You can estimate your potential monthly passive potential income based on your current referral stats.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2"><span style="font-weight: 400;">Play with the percentage of referrals who subscribe and the average monthly subscription.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2"><span style="font-weight: 400;">See your potential income up to 5 years from the values you enter.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2"><span style="font-weight: 400;">Social media has become huge. With over 4.62 billion social media users as of January 2022, the opportunity to grow a large following as well as make residual income is easier than ever.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2"><span style="font-weight: 400;">With engaging content, it's much easier to generate a large following in social media because there's more people in social media than ever before.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li style="font-weight: 400;" aria-level="2"><span style="font-weight: 400;">With QuickCam, it's now possible to generate content that will attract other content creators, including big influencers with a large following.</span></li>
</ul>
"""
            case .quickCam:
                return """
<ul>
<li><span style="font-weight: 400;">QuickCam is for anyone with a smartphone.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li><span style="font-weight: 400;">QuickCam is for people who want to create cool content.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li><span style="font-weight: 400;">QuickCam is for anyone who wants to make money on a ongoing monthly basis by referring QuickCam with powerful built-in referral tools.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li><span style="font-weight: 400;">QuickCam is for clubs, organizations, churches and non-profits who want to make money on a ongoing monthly basis for fundraising by referring QuickCam to members and supporters.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li><span style="font-weight: 400;">QuickCam is for beginners with little or no experience creating content as well as advanced content creators.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li><span style="font-weight: 400;">QuickCam is great for moms, dads and family members creating memorable videos for family entertainment.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li><span style="font-weight: 400;">QuickCam is for those who are not in social media as well as seasoned users of social media.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li><span style="font-weight: 400;">QuickCam is for those who want to begin creating and sharing social media content.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li><span style="font-weight: 400;">QuickCam is for those who want to become influencers in social media.</span></li>
</ul>
<p>&nbsp;</p>
<ul>
<li><span style="font-weight: 400;">QuickCam is for social media influencers who want to become bigger influencers!</span></li>
</ul>
"""
            }
        }
        
        var isLastStep: Bool {
            return self == .yourGoal
        }
        
        var isFirstStep: Bool {
            return self == .referralCommissionProgram
        }
        
        var hideTryNowButton: Bool {
            switch self {
            case .potentialCalculator, .referralWizard:
                return false
            default:
                return true
            }
        }

        case referralCommissionProgram = 0
        case quickCam
        case referralWizard
        case contactManagerTools
        case potentialCalculator
        case fundraising
        case yourGoal
    }
}

class OnBoardingViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var centerPlaceholderView: NSLayoutConstraint!
    @IBOutlet weak var heightPlaceholderView: NSLayoutConstraint!
    @IBOutlet weak var foundingMemberImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var subscriptionStatusLabel: UILabel!
    @IBOutlet weak var createContentStepIndicatorView: StepIndicatorView!
    @IBOutlet weak var mobileDashboardStepIndicatorView: StepIndicatorView!
    @IBOutlet weak var makeMoneyStepIndicatorView: StepIndicatorView!
    @IBOutlet weak var mainContainerStackView: UIStackView!
    @IBOutlet weak var createContentStackView: UIView!
    @IBOutlet weak var makeMoneyStackView: UIView!
    @IBOutlet weak var mobileDashboardStackView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var makeMoneyTitleLabel: UILabel!
    @IBOutlet weak var mobileDashboardTitleLabel: UILabel!
    @IBOutlet weak var createContentTitleLabel: UILabel!
    @IBOutlet var makeMoneyCategoriesLabels: [UILabel]!
    @IBOutlet var mobileDashboardCategoriesLabels: [UILabel]!
    @IBOutlet var createContentCategoriesLabels: [UILabel]!
    @IBOutlet var lastOptionCreateContent: UIStackView!
    @IBOutlet weak var lblAppInfo: UILabel! {
        didSet {
            lblAppInfo.text = "\(Constant.Application.displayName) - 1.2(39.\(Constant.Application.appBuildNumber))"
        }
    }
    @IBOutlet weak var imgAppLogo: UIImageView! {
        didSet {
            setupUI()
        }
    }

    var showPopUpView: Bool = false
    var shouldShowFoundingMemberView: Bool = true
    var previousSelectedQuickStartMenu: QuickStartOption = .createContent
    var previousDate = Date()
    var fromNavigation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.isHidden = false
        setupView()
        switch Defaults.shared.selectedQuickStartOption {
        case .makeMoney:
            self.mainContainerStackView.removeArrangedSubview(makeMoneyStackView)
            self.mainContainerStackView.insertArrangedSubview(makeMoneyStackView, at: 0)
            self.mainContainerStackView.removeArrangedSubview(createContentStackView)
            self.mainContainerStackView.insertArrangedSubview(createContentStackView, at: 2)
            self.mainContainerStackView.setNeedsLayout()
            self.mainContainerStackView.layoutIfNeeded()
        default: break
        }
    }
    
    private func setupUI() {
        #if SOCIALCAMAPP
        imgAppLogo.image = R.image.socialCamSplashLogo()
        #elseif VIRALCAMAPP
        imgAppLogo.image = R.image.viralcamrgb()
        #elseif SOCCERCAMAPP || FUTBOLCAMAPP
        imgAppLogo.image = R.image.soccercamWatermarkLogo()
        #elseif QUICKCAMAPP
        imgAppLogo.image = R.image.ssuQuickCam()
        #elseif SNAPCAMAPP
        imgAppLogo.image = R.image.snapcamWatermarkLogo()
        #elseif SPEEDCAMAPP
        imgAppLogo.image = R.image.ssuSpeedCam()
        #elseif TIMESPEEDAPP
        imgAppLogo.image = R.image.timeSpeedWatermarkLogo()
        #elseif FASTCAMAPP
        imgAppLogo.image = R.image.ssuFastCam()
        #elseif BOOMICAMAPP
        imgAppLogo.image = R.image.boomicamWatermarkLogo()
        #elseif VIRALCAMLITEAPP
        imgAppLogo.image = R.image.viralcamLiteWatermark()
        #elseif FASTCAMLITEAPP
        imgAppLogo.image = R.image.ssuFastCamLite()
        #elseif QUICKCAMLITEAPP || QUICKAPP
        imgAppLogo.image = (Defaults.shared.releaseType == .store) ? R.image.ssuQuickCam() : R.image.ssuQuickCamLite()
        #elseif SPEEDCAMLITEAPP
        imgAppLogo.image = R.image.speedcamLiteSsu()
        #elseif SNAPCAMLITEAPP
        imgAppLogo.image = R.image.snapcamliteSplashLogo()
        #elseif RECORDERAPP
        imgAppLogo.image = R.image.socialScreenRecorderWatermarkLogo()
        #else
        imgAppLogo.image = R.image.pic2artWatermarkLogo()
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillStepIndicatorViews()
    }
    
    func fillStepIndicatorViews() {
        for quickStartOption in Defaults.shared.quickStartCategories ?? [] {
            for (index, quickStartItem) in (quickStartOption.Items ?? []).enumerated() {
                if quickStartOption.catId == "create_engaging_content" {
                    if quickStartItem.isread ?? false {
                        createContentStepIndicatorView.finishedStep = index
                    }
                }
                if quickStartOption.catId == "make_money_referring_quickCam" {
                    if quickStartItem.isread ?? false {
                        makeMoneyStepIndicatorView.finishedStep = index
                    }
                }
                if quickStartOption.catId == "mobile_dashboard" {
                    if quickStartItem.isread ?? false {
                        mobileDashboardStepIndicatorView.finishedStep = index
                    }
                }
            }
        }
//        for option in Defaults.shared.createContentOptions {
//            createContentStepIndicatorView.finishedStep = option
//        }
//        for option in Defaults.shared.mobileDashboardOptions {
//            mobileDashboardStepIndicatorView.finishedStep = option
//        }
//        for option in Defaults.shared.makeMoneyOptions {
//            makeMoneyStepIndicatorView.finishedStep = option
//        }
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func didTapMakeMoneyClick(_ sender: UIButton) {
        let hasAllowAffiliate = Defaults.shared.currentUser?.isAllowAffiliate ?? false
        if hasAllowAffiliate {
            self.setNavigation()
        } else {
            guard let makeMoneyReferringVC = R.storyboard.onBoardingView.makeMoneyReferringViewController() else { return }
            navigationController?.pushViewController(makeMoneyReferringVC, animated: true)
        }
    }
    
    
    @IBAction func createContent(_ sender: UIButton) {
        Defaults.shared.isSignupLoginFlow = true
        if let storySettingsVC = R.storyboard.storyCameraViewController.storyCameraViewController() {
            storySettingsVC.isFromCameraParentView = true
            navigationController?.pushViewController(storySettingsVC, animated: true)
        }
//        let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
//        Utils.appDelegate?.window?.rootViewController = rootViewController
    }
    
    @IBAction func didTapMobileDashboardClick(_ sender: UIButton) {
//        let rootViewController: UIViewController? = R.storyboard.pageViewController.pageViewController()
//        if let pageViewController = rootViewController as? PageViewController,
//           let navigationController = pageViewController.pageControllers.first as? UINavigationController,
//           let settingVC = R.storyboard.storyCameraViewController.storySettingsVC() {
//            navigationController.viewControllers.append(settingVC)
//        }
//        Utils.appDelegate?.window?.rootViewController = rootViewController
        let storySettingsVC = R.storyboard.storyCameraViewController.storySettingsVC()!
        navigationController?.pushViewController(storySettingsVC, animated: true)
    }
    
    @IBAction func didTapFollowSocialMedia(_ sender: UIButton) {
        guard let option = QuickStartSocialMediaOption(rawValue: sender.tag) else {
            return
        }
        var urlString = ""
        switch option {
        case .tiktok:
            urlString = "https://www.tiktok.com/@quickcamapp"
        case .instagram:
            urlString = "https://www.instagram.com/quickcam.app/?hl=en"
        case .youtube:
            urlString = "https://www.youtube.com/channel/UCigeTuaTcsLXBfnVFnBgbdA"
        case .facebook:
            urlString = "https://www.facebook.com/QuickCamTM"
        case .twitter:
            urlString = "https://twitter.com/QuickCamApp"
        case .linkedin:
            urlString = "https://www.linkedin.com/company/quickcamasia/"
        }
        if let url = URL(string: urlString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func didTapCloseClick(_ sender: UIButton) {
        popupView.isHidden = true
    }
    
    @IBAction func didTapOnCreateContentSteps(_ sender: UIButton) {
        openQuickStartOptionDetail(quickStartOption: .createContent, tag: sender.tag)
    }
    
    @IBAction func didTapOnMobileDashboardSteps(_ sender: UIButton) {
        openQuickStartOptionDetail(quickStartOption: .mobileDashboard, tag: sender.tag)
    }
    
    @IBAction func didTapOnMakeMoneySteps(_ sender: UIButton) {
        openQuickStartOptionDetail(quickStartOption: .makeMoney, tag: sender.tag)
    }
    
    func openQuickStartOptionDetail(quickStartOption: QuickStartOption, tag: Int) {
        var viewControllers: [UIViewController] = []
        switch quickStartOption {
        case .createContent:
            var options = Defaults.shared.createContentOptions
            options.append(tag)
            Defaults.shared.createContentOptions = Array(Set(options))
            for i in 0...tag {
                if let quickStartDetail = R.storyboard.onBoardingView.quickStartOptionDetailViewController() {
                    quickStartDetail.selectedQuickStartCategory = Defaults.shared.quickStartCategories?.first(where: { return $0.catId == "create_engaging_content" })
                    quickStartDetail.selectedQuickStartItem = Defaults.shared.quickStartCategories?.first(where: { return $0.catId == "create_engaging_content" })?.Items?[i]
                    if self.previousSelectedQuickStartMenu != .createContent {
                        self.previousSelectedQuickStartMenu = .createContent
                        self.previousDate = Date()
                    }
                    quickStartDetail.guidTimerDate = self.previousDate
                    viewControllers.append(quickStartDetail)
                }
            }
        case .mobileDashboard:
            var options = Defaults.shared.mobileDashboardOptions
            options.append(tag)
            Defaults.shared.mobileDashboardOptions = Array(Set(options))
            for i in 0...tag {
                if let quickStartDetail = R.storyboard.onBoardingView.quickStartOptionDetailViewController() {
                    quickStartDetail.selectedQuickStartCategory = Defaults.shared.quickStartCategories?.first(where: { return $0.catId == "mobile_dashboard" })
                    quickStartDetail.selectedQuickStartItem = Defaults.shared.quickStartCategories?.first(where: { return $0.catId == "mobile_dashboard" })?.Items?[i]
                    if self.previousSelectedQuickStartMenu != .mobileDashboard {
                        self.previousSelectedQuickStartMenu = .mobileDashboard
                        self.previousDate = Date()
                    }
                    quickStartDetail.guidTimerDate = self.previousDate
                    viewControllers.append(quickStartDetail)
                }
            }
        case .makeMoney:
            var options = Defaults.shared.makeMoneyOptions
            options.append(tag)
            Defaults.shared.makeMoneyOptions = Array(Set(options))
            for i in 0...tag {
                if let quickStartDetail = R.storyboard.onBoardingView.quickStartOptionDetailViewController() {
                    quickStartDetail.selectedQuickStartCategory = Defaults.shared.quickStartCategories?.first(where: { return $0.catId == "make_money_referring_quickCam" })
                    quickStartDetail.selectedQuickStartItem = Defaults.shared.quickStartCategories?.first(where: { return $0.catId == "make_money_referring_quickCam" })?.Items?[i]
                    if self.previousSelectedQuickStartMenu != .makeMoney {
                        self.previousSelectedQuickStartMenu = .makeMoney
                        self.previousDate = Date()
                    }
                    quickStartDetail.guidTimerDate = self.previousDate
                    viewControllers.append(quickStartDetail)
                }
            }
        }
        UserSync.shared.setOnboardingUserFlags()
        navigationController?.viewControllers.append(contentsOf: viewControllers)
    }
    
}

extension OnBoardingViewController {
    
    func setupView() {
        self.setUpQuickStartData()
        popupView.isHidden = !self.showPopUpView
        UserSync.shared.syncUserModel { isCompleted in
            UserSync.shared.getOnboardingUserFlags { isCompleted in
                self.fillStepIndicatorViews()
            }
            UserSync.shared.getQuickStartCategories(completion: { _ in
                self.setUpQuickStartData()
            })
            if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
                self.userImageView.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
            }
            let isFoundingMember = Defaults.shared.currentUser?.badges?.filter({ return $0.badge?.code == "founding-member" }).count ?? 0 > 0
            if isFoundingMember {
                self.foundingMemberImageView.isHidden = false
                self.centerPlaceholderView.constant = -30
                self.heightPlaceholderView.constant = 211
            } else {
                self.foundingMemberImageView.isHidden = true
                self.centerPlaceholderView.constant = 0
                self.heightPlaceholderView.constant = 110
            }
            self.userNameLabel.text = Defaults.shared.currentUser?.firstName
            if let badgearray = Defaults.shared.currentUser?.badges {
                for parentbadge in badgearray {
                    let badgeCode = parentbadge.badge?.code ?? ""
                    if badgeCode == Badges.SUBSCRIBER_IOS.rawValue {
                        let subscriptionType = parentbadge.meta?.subscriptionType ?? ""
                        let finalDay = Defaults.shared.getCountFromBadge(parentbadge: parentbadge)
                        if subscriptionType == SubscriptionTypeForBadge.TRIAL.rawValue {
                            if finalDay == "7" {
                                self.subscriptionStatusLabel.text = "Today is the last day of your 7-Day Premium Free Trial. Upgrade now to access these features"
                            } else {
                                var fday = 0
                                if let day = Int(finalDay) {
                                    if day <= 7 && day >= 0
                                    {
                                        fday = 7 - day
                                    }
                                }
                                if fday == 0{
                                    self.subscriptionStatusLabel.text = "Your 7-Day Premium Free Trial period has expired. Upgrade now to access these features."
                                } else {
                                    self.subscriptionStatusLabel.text = "You have \(fday) days left on your free trial. Subscribe now and earn your subscription badge."
                                }
                               
                            }
                        } else if subscriptionType == SubscriptionTypeForBadge.FREE.rawValue {
                            self.subscriptionStatusLabel.text = "Your 7-Day Premium Free Trial is over. Subscribe now to continue using the Basic, Advanced or Premium features."
                        }
                    }
                }
            }
        }
    }
    
    func setNavigation() {
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL , !userImageURL.isEmpty, userImageURL != "undefined" {
            if let contactWizardController = R.storyboard.contactWizardwithAboutUs.contactImportVC() {
                contactWizardController.isFromOnboarding = true
                navigationController?.pushViewController(contactWizardController, animated: true)
            }
        } else {
            if let editProfileController = R.storyboard.refferalEditProfile.refferalEditProfileViewController() {
                editProfileController.isFromOnboarding = true
                navigationController?.pushViewController(editProfileController, animated: true)
            }
        }
    }
    
    func setUpQuickStartData() {
        if Defaults.shared.quickStartCategories?.count == 3 {
            if let createContent = Defaults.shared.quickStartCategories?.filter({ return $0.catId == "create_engaging_content" }).first {
                self.createContentTitleLabel.text = createContent.label
            }
            if let makeMoney = Defaults.shared.quickStartCategories?.filter({ return $0.catId == "make_money_referring_quickCam" }).first {
                self.makeMoneyTitleLabel.text = makeMoney.label
            }
            if let mobileDashboard = Defaults.shared.quickStartCategories?.filter({ return $0.catId == "mobile_dashboard" }).first {
                self.mobileDashboardTitleLabel.text = mobileDashboard.label
            }
        }
        if let createContent = Defaults.shared.quickStartCategories?.filter({ return $0.catId == "create_engaging_content" }).first, createContent.Items?.count == createContentCategoriesLabels.count {
            for label in createContentCategoriesLabels {
                label.text = createContent.Items?[label.tag].title
            }
        }
        if let createContent = Defaults.shared.quickStartCategories?.filter({ return $0.catId == "make_money_referring_quickCam" }).first, createContent.Items?.count == makeMoneyCategoriesLabels.count {
            for label in makeMoneyCategoriesLabels {
                label.text = createContent.Items?[label.tag].title
            }
        }
        if let createContent = Defaults.shared.quickStartCategories?.filter({ return $0.catId == "mobile_dashboard" }).first, createContent.Items?.count == mobileDashboardCategoriesLabels.count {
            for label in mobileDashboardCategoriesLabels {
                label.text = createContent.Items?[label.tag].title
            }
        }
        self.fillStepIndicatorViews()
    }
    
}
