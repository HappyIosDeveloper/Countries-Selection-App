//
//  Countries_Selection_AppTests.swift
//  Countries Selection AppTests
//
//  Created by Ahmadreza on 4/8/22.
//

import XCTest
@testable import Countries_Selection_App

// MARK: - ViewController tests
class Countries_Selection_AppTests: XCTestCase {

    func getViewController()-> UIViewController {
        let bundle = Bundle(for: ViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController")
        return vc
    }
    
    func test_viewController_tableViewSetup() {
        let vc = getViewController() as! ViewController
        vc.view.layoutIfNeeded()
        XCTAssertNotNil(vc.tableView.delegate)
        XCTAssertNotNil(vc.tableView.dataSource)
        XCTAssertEqual(vc.tableView.numberOfRows(inSection: 0), vc.countries.count)
    }
}

// MARK: - CountrySelectViewController tests
extension Countries_Selection_AppTests {
    
    func getCountrySelectViewController()-> UIViewController {
        let bundle = Bundle(for: CountrySelectViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "CountrySelectViewController")
        return vc
    }
    
    func test_csvc_tableViewSetup() {
        let vc = getCountrySelectViewController() as! CountrySelectViewController
        vc.view.layoutIfNeeded()
        XCTAssertNotNil(vc.tableView.delegate)
        XCTAssertNotNil(vc.tableView.dataSource)
        let vm = CountrySelectViewModel {
        } showIndicator: {
        } showNetworkError: {
        } stopRefresh: {
        }
        XCTAssertEqual(vc.tableView.numberOfRows(inSection: 0), vm.countries.count)
    }
    
    func test_csvc_gettingData() {
        let exp = expectation(description: "getting data")
        var countries:[Country] = []
        WebService.shared.getAllCountries { response in
            switch response {
            case .failure(_):
                exp.fulfill()
            case .success(let apiCountries):
                countries = apiCountries
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 5) { _ in
            XCTAssertFalse(countries.isEmpty)
        }
    }
    
    func test_csvc_searchFunctionality() {
        let vm = CountrySelectViewModel {
        } showIndicator: {
        } showNetworkError: {
        } stopRefresh: {
        }
        vm.countries = [Country(name: CountryName(common: "Iran", official: "Iran")),
                        Country(name: CountryName(common: "USA", official: "USA")),
                        Country(name: CountryName(common: "Iraq", official: "Iraq"))]
        vm.search(with: "iran")
        XCTAssertEqual(vm.countries.filter({$0.isVisible ?? false}).count, 1)
    }
}
