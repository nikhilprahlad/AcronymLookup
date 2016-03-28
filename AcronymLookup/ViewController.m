//
//  ViewController.m
//  AcronymLookup
//
//  Created by Nikhil Prahlad on 03/27/16.
//  Copyright (c) 2015 Nikhil Prahlad. All rights reserved.
//

#import "ViewController.h"

static NSString *const LongFormsRequestURL = @"http://www.nactem.ac.uk/software/acromine/dictionary.py";
static NSString *const NoDataAlertTitle = @"No Data Found";
static NSString *const NoDataAlertMessage = @"There is no data matching the entered acronym";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *searchResultsList;
@property (strong, nonatomic) NSArray *longFormsList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.longFormsList.count > 0) {
        return [[self.longFormsList firstObject] count];
    }
    return self.longFormsList.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [[[self.longFormsList firstObject] objectAtIndex:indexPath.row] objectForKey:@"lf"];

    return cell;
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
    //Add progress indicator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //Perform request to fetch the long forms of entered data.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:searchBar.text forKey:@"sf"];
    
    [manager GET:LongFormsRequestURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        self.longFormsList = [responseDictionary valueForKey:@"lfs"];
        
        if (self.longFormsList == nil || self.longFormsList.count == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NoDataAlertTitle
                                                                message:NoDataAlertMessage
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.searchResultsList reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length] == 0) {
        self.longFormsList = nil;
        [self.searchResultsList reloadData];
        
    }
}


@end
