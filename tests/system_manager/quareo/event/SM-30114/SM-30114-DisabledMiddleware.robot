*** Settings ***

Library   ../../../../py_sources/logigear/setup.py        
Library   ../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmEventLogFilterPage${PLATFORM}.py
Library    ../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmEventNotificationProfilesPage${PLATFORM}.py
Library   ../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmPriorityEventSettingsPage${PLATFORM}.py
Library   ../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py   

Resource    ../../../../resources/constants.robot

Default Tags    Quareo Event
Force Tags    SM-30114

Suite Setup    Run Keywords    Replace Substring In Text File    ${MIDDLEWARE_CONFIG_LOCATION}    ${MIDDLEWARE_ENABLED_KEY_TRUE}    ${MIDDLEWARE_ENABLED_KEY_FALSE}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}    
    
Suite Teardown    Run Keywords    Close Browser
    ...    AND    Replace Substring In Text File    ${MIDDLEWARE_CONFIG_LOCATION}    ${MIDDLEWARE_ENABLED_KEY_FALSE}    ${MIDDLEWARE_ENABLED_KEY_TRUE}

*** Test Cases ***
(Bulk_SM-30114-05-06-07)_Verify "Plug Inserted In Quareo Port" And "Plug Removed From Quareo Port" Are Not Added When Quareo Is Disabled        
    
    ${event_name}    Set Variable    Event_30114_06
    # SM-30114-05: Verify "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are not displayed into Administration -> Priority Event Settings
    # 3. Go to Administration -> Priority Event Settings
    # VP: "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are not displayed
    Select Main Menu    ${Administration}/${Events}    ${Priority Event Settings}    
    Check Event Not Exist At Priority Event Settings    ${Plug Inserted in Quareo Port},${Plug Removed from Quareo Port} 
              
    # SM-30114-07: Verify "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are not displayed into Administration -> Event Log Filters (applied for Event Log)
    # 3. Go to Administration -> Event Log Filters
    # VP: "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are not displayed
	
    Select Main Menu    ${Administration}/${Events}    ${Event Log Filters}    
    Click Add Event Log Filter
	Select Event Log Filter Tab    ${iPatch Events}
	Check Event Not Exist In Add Event Log Filter    ${Plug Inserted in Quareo Port},${Plug Removed from Quareo Port}
    Click Event Log Filter Page Cancel Button  
    
    # SM-30114-06: Verify "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are not dispalyed into Administration -> Event Notification Profiles -> Add Profile - Select Events
    # 3. Go to Administration -> Event Notification Profiles -> Add Profile - Select Events
    # VP: "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are not displayed              
    Select Main Menu    ${Administration}/${Events}    ${Event Notification Profiles}
    Add Event Notification Profile    profileName=${event_name}    submit=${False}	
    Check Event Not Exist On Event Notification Profiles Page    ${Plug Inserted in Quareo Port},${Plug Removed from Quareo Port}
	