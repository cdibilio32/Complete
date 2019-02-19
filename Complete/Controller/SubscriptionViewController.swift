//
//  SubscriptionViewController.swift
//  Complete
//
//  Created by Chuck Dibilio on 2/8/19.
//  Copyright © 2019 Chuck Dibilio. All rights reserved.
//

import UIKit

class SubscriptionViewController: UIViewController, UIScrollViewDelegate {
    
    
    // --- Outlets ---
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var subOption1Container: UIView!
    @IBOutlet var subOption2Container: UIView!
    @IBOutlet var subOption1Header: UIView!
    @IBOutlet var subOption2Header: UIView!
    @IBOutlet var purchaseButton: UIButton!
    @IBOutlet var pageController: UIPageControl!
    @IBOutlet var navView: UIView!
    @IBOutlet var navViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var navViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var cornerFixer1: UIView!
    @IBOutlet var cornerFixer2: UIView!
    @IBOutlet var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var checkMark1: UIImageView!
    @IBOutlet var checkMark2: UIImageView!
    @IBOutlet var activitySpinner: UIActivityIndicatorView!
    @IBOutlet var activitySpinnerContainer: UIView!
    
    
    // --- Instance Variables
    var slides:[Slide] = []
    var subscription = "annual"
    var subToChannelVCDelegate:SubscriptionVCToChannelVC?
    var subToTaskVCDelegate:SubscriptionVCToTaskVC?
    var cameFromVC:String!
    
    
    
    
    // --- Actions ---
    // Purchase Subscription OPtion
    @IBAction func purchaseBtnPressed(_ sender: Any) {
        // Show Activity Spinner
        debugPrint("start")
        
        PurchaseManager.instance.purchaseSubscription(renewing: subscription, activityIndicator: activitySpinner, activityContainer: activitySpinnerContainer) { (success) in
            if success {
                // Update banner ads
                if self.cameFromVC == "channelVC" {
                    self.subToChannelVCDelegate?.updateBannerAds()
                }
                else {
                    self.subToTaskVCDelegate?.updateBannerAdsInTask()
                }
//                self.activitySpinner.stopAnimating()
//                self.activitySpinner.isHidden = true
            }
            else {
                debugPrint("Unsuccessful purchase")
            }
        }
    }
    
    // Exit Page
    @IBAction func closeBtnPressed(_ sender: Any) {
        debugPrint("exit")
        navigationController?.popViewController(animated: true)
    }
    
    // Select Annual Subscription
    @IBAction func annualSubButtonPressed(_ sender: Any) {
        // Change selection value
        subscription = "annual"
        
        // Format Annual Subscription
        subOption1Header.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        cornerFixer1.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        subOption1Container.layer.borderColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        checkMark1.isHidden = false
        
        // Format Monthly Subscription
        subOption2Header.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        cornerFixer2.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        subOption2Container.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        checkMark2.isHidden = true
    }
    
    // Select Monthly Subscription
    @IBAction func monthlySubButtonPressed(_ sender: Any) {
        // Change selection value
        subscription = "monthly"
        
        // Format Monthly subscription
        subOption2Header.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        cornerFixer2.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        subOption2Container.layer.borderColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        checkMark2.isHidden = false
        
        // Format Annual Subscription
        subOption1Header.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        cornerFixer1.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        subOption1Container.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        checkMark1.isHidden = true
    }
    
    
    
    
    
    // --- Load Functions ---
    override func viewDidLoad() {
        super.viewDidLoad()

        // Format View
        formatViews()
        setUpPageScroller()
        navigationBarFormatting()

        // Set Up Delegates
        scrollView.delegate = self
    }
    
    
    
    
    
    
    
    
    
    // --- Helper Functions ---
    // --- View ---
    // Format views of subviews
    func formatViews() {
        // Option 1
        subOption1Container.layer.cornerRadius = 10
        subOption1Container.layer.borderWidth = 1
        subOption1Container.layer.borderColor = #colorLiteral(red: 0, green: 0.5333333333, blue: 1, alpha: 1)
        subOption1Container.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        subOption1Header.layer.cornerRadius = 10
        subOption1Header.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        cornerFixer1.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        checkMark1.isHidden = false
        
        // Option 2
        subOption2Container.layer.cornerRadius = 10
        subOption2Container.layer.borderWidth = 1
        subOption2Container.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        subOption2Container.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        subOption2Header.layer.cornerRadius = 10
        subOption2Header.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        cornerFixer2.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        checkMark2.isHidden = true
        
        // Purchase button
        purchaseButton.layer.cornerRadius = 10
        purchaseButton.layer.borderWidth = 1
        purchaseButton.layer.borderColor = #colorLiteral(red: 0, green: 0.5333333333, blue: 1, alpha: 1)
        purchaseButton.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        
        // Activity Spinner
        let transform = CGAffineTransform(scaleX: CGFloat(2), y: CGFloat(2))
        activitySpinner.transform = transform
        activitySpinner.isHidden = true
        
        // Activity Spinner Container
        activitySpinnerContainer.isHidden = true
        activitySpinnerContainer.layer.cornerRadius = 10
        activitySpinnerContainer.layer.borderWidth = 2
        activitySpinnerContainer.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    // Set Up ScrollView and Pagination
    func setUpPageScroller() {
        slides = createSlides()
        setUpScrollView(slides: slides)
        
        pageController.numberOfPages = slides.count
        pageController.currentPage = 0
        view.bringSubview(toFront: pageController)
    }
    
    // Update navigation bar based on ndevice - update for
    func navigationBarFormatting() {
        if UIDevice.current.modelName.contains("iPhone10") {
            // Top Constraint
            navViewTopConstraint.isActive = false
            navView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
            
            // Height
            navViewHeightConstraint.isActive = false
            navView.heightAnchor.constraint(equalToConstant: navView.frame.height + 35).isActive = true
            scrollViewTopConstraint.constant = scrollViewTopConstraint.constant - 10
        }
    }
    
    
    
    
    
    // --- Helper Methods For Page Scroller ---
    // Create Slides for page scroll
    func createSlides() -> [Slide] {
        
        let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide1.iconView.image = UIImage(named: "icons8-data-recovery-filled-100")
        slide1.titleView.text = "Unlimited Data"
        slide1.descriptionView.text = "Jot everything down and clear your mind completely."
        slide1.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        
        let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide2.iconView.image = UIImage(named: "icons8-no-access-filled-100 (1)")
        slide2.titleView.text = "No Ads"
        slide2.descriptionView.text = "Let your mind free without the distraction of ads."
        slide2.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        
        let slide3:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide3.iconView.image = UIImage(named: "icons8-automation-filled-500")
        slide3.titleView.text = "Future Features"
        slide3.descriptionView.text = "Gain access to features coming to JotItt like task sharing and notifications."
        slide3.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.6156862745, blue: 1, alpha: 1)
        
        return [slide1, slide2, slide3]
    }
    
    // Set Up Scroll View
    func setUpScrollView(slides:[Slide]) {
        scrollView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: view.frame.width, height: scrollView.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width*CGFloat(slides.count), height: scrollView.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: CGFloat(0), width: view.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    
    
    
    
    
    
    
    
    // --- Delegates ---
    // --- Scroll View Delegate Functinos ---
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Update Page Conroller
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageController.currentPage = Int(pageIndex)
    }
}









// --- Protocols ---
// Connection to channelVC (really trying to get to taskVC)
protocol SubscriptionVCToChannelVC {
    func updateBannerAds()
}

// Connection to TaskVC
protocol  SubscriptionVCToTaskVC {
    func updateBannerAdsInTask()
}
