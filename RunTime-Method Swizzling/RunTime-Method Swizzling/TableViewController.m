//
//  TableViewController.m
//  RunTime-Method Swizzling
//
//  Created by yejunyou on 2018/11/27.
//  Copyright © 2018 FetureVersion. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()
@property (nonatomic, strong) NSMutableArray *dataList;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataList = [@[@"111", @"222"] mutableCopy];
}

- (IBAction)refresh:(id)sender {
    static NSInteger i = 0;
    if (++ i % 2 == 0) {
        self.dataList = [@[@"111", @"222",@"333"] mutableCopy];
    }else{
        self.dataList  = NSMutableArray.array;
    }
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    
    cell.textLabel.text = _dataList[indexPath.row];
    return cell;
}


- (NSMutableArray *)dataList
{
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}
@end
