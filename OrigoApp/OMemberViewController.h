//
//  OMemberViewController.h
//  OrigoApp
//
//  Created by Anders Blehr on 17.10.12.
//  Copyright (c) 2012 Rhelba Creations. All rights reserved.
//

#import "OrigoApp.h"

@interface OMemberViewController : OTableViewController<OTableViewListDelegate, OTableViewInputDelegate, ORegistrantExaminerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, ABPeoplePickerNavigationControllerDelegate, OConnectionDelegate> {
@private
    OMembership *_membership;
    OMember *_member;
    OOrigo *_origo;
    
    OInputField *_nameField;
    OInputField *_dateOfBirthField;
    OInputField *_mobilePhoneField;
    OInputField *_emailField;
    
    OMember *_candidate;
    NSArray *_candidateResidences;
    
    ORegistrantExaminer *_examiner;
}

@end
