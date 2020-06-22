*** Settings ***
Library   ../../../../py_sources/logigear/setup.py        
Library   ../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py      
Library   ../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmEventLogFilterPage${PLATFORM}.py
Library    ../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmEventNotificationProfilesPage${PLATFORM}.py
Library   ../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmPriorityEventSettingsPage${PLATFORM}.py
Library   ../../../../py_sources/logigear/page_objects/system_manager/reports/reports/ReportsPage${PLATFORM}.py    
Library   ../../../../py_sources/logigear/page_objects/system_manager/administration/system_manager/AdmEmailServerPage${PLATFORM}.py    
Library   ../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py    

Resource    ../../../../resources/constants.robot

Default Tags    Quareo Event
Force Tags    SM-30114

*** Test Cases ***
(Bulk_SM-30114-01-03-04)_Verify "Plug Inserted In Quareo Port" And "Plug Removed From Quareo Port" Are Added When Quareo Is Enabled
    [Setup]    Run Keywords    Set Test Variable    ${event_name}    Event_30114_03  
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
        
    [Teardown]    Run Keywords   Delete Event Log Filter    ${event_name}
    ...    AND    Select Main Menu    ${Reports}   
    ...    AND    Delete Report    ${event_name}
    ...    AND    Close Browser
    
    [Tags]    Sanity
    
    # SM-30114-01: Verify "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are added into Administration -> Priority Event Settings
    # 3. Go to Administration -> Priority Event Settings
    # VP: "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are added with the checkbox default is enabled and not checked.
    Select Main Menu    ${Administration}/${Events}    ${Priority Event Settings}    
    Check Event Exist At Priority Event Settings    ${Plug Inserted in Quareo Port},${Plug Removed from Quareo Port}   
    Check Multiple Checkboxes States At Priority Event Settings    events=${Plug Inserted in Quareo Port},${Plug Removed from Quareo Port}    enabled=${True}    selected=${False}           

    # SM-30114-04: Verify "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are added into RePort -> Event Log Details -> Event Type (filter)
    # 3. Go to Reports -> Event Log Details -> Event Type (filter)
    Select Main Menu    ${Reports}   
    Delete Report    ${event_name}    
    Add Report    ${Events}    ${Event Log Details}    ${event_name}    confirm=${TRUE}
    Check Object Exist On Multiple Select Filter    ${Event Type}    ${Plug Inserted in Quareo Port},${Plug Removed from Quareo Port}           
     
    # SM-30114-03: Verify "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are added into Administration -> Event Log Filters (applied for Event Log)
    # 3. Go to Administration -> Event Log Filters
	# 4. Click Add button and observe the data in iPatch Events
	# VP:"Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are added with the checkbox default is enabled and not checked.
    Select Main Menu    ${Administration}/${Events}    ${Event Log Filters}     
    Delete Event Log Filter    ${event_name}   
	Click Add Event Log Filter
	Select Event Log Filter Tab    ${iPatch Events}
	Check Multiple Checkboxes States In Add Event Log Filter    events=${Plug Inserted in Quareo Port},${Plug Removed from Quareo Port}    enabled=${True}    selected=${False}       
	
	# 5. Enter name, select "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port", then save event log filter
	Fill Data In Add Event Log Filter    eventName=${event_name}    events=${Plug Inserted in Quareo Port},${Plug Removed from Quareo Port}    save=${True}
	
	# 6. Select the created event and edit
	Edit Event Log Filter    eventName=${event_name}    
	# 7. Observe the data in iPatch Events
	# VP: "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are saved with the checkboxes are checked.   
    Check Multiple Checkboxes States In Add Event Log Filter    events=${Plug Inserted in Quareo Port},${Plug Removed from Quareo Port}    enabled=${True}    selected=${True}
    Click Event Log Filter Page Cancel Button               

SM-30114-02_Verify "Plug Inserted In Quareo Port" And "Plug Removed From Quareo Port" Are Added Into Administration -> Event Notification Profiles -> Add/Edit Profile - Select Events
    [Setup]    Run Keywords    Set Test Variable    ${profile_name}    Event_30114_02
    ...    AND    Set Test Variable    ${email_server_name}    Email_Server_30114_02    
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
        
    [Teardown]    Run Keywords    Select Main Menu    ${Administration}/${Events}    ${Event Notification Profiles}    
    ...    AND    Delete Event Notification Profile    ${profile_name}
    ...    AND    Select Main Menu    ${Administration}/${System Manager}    ${Email Servers}    
    ...    AND    Delete Email Server    ${email_server_name}        
    ...    AND    Close Browser
    
    [Tags]    Sanity
        
    # SM-30114-02: Verify "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are added into Administration -> Event Notification Profiles -> Add/Edit Profile - Select Events
    # 3. Create an email server in Administration > Email Server
    Select Main Menu    ${Administration}/${System Manager}    ${Email Servers}
    Add Email Server    ${email_server_name}    ${EMAIL_NAME}     ${EMAIL_SERVER}    
    Select Main Menu    ${Site Manager}  

    # 4. Go to Administration -> Event Notification Profiles
	# 5. Click Add button, enter name, and go to Select Events
	# VP: "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are added with the checkbox default is enabled and not checked.
    Select Main Menu    ${Administration}/${Events}    ${Event Notification Profiles}
    Add Event Notification Profile    profileName=${profile_name}    submit=${False}	
    Check Event Exist On Event Notification Profiles Page    ${Plug Inserted in Quareo Port},${Plug Removed from Quareo Port}    
    Check Multiple Checkboxes States On Event Notification Profiles Page    events=${Plug Inserted in Quareo Port},${Plug Removed from Quareo Port}    enabled=${True}    selected=${False}       

	# 6. Select "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" and do the remaing steps to complete Add a Profiles.	
    Fill Event Notification Profile    events=${Plug Inserted in Quareo Port}/${Plug Removed from Quareo Port}    locationPath=${SITE_NODE}
    ...    sendEmail=${True}    emailServer=${email_server_name}    recipients=${EMAIL_NAME} 	
    Submit Event Notification Profile    ${profile_name}

	# 7. Select the created profile and edit	
	# 8. Go to Select Events step and observe
	# VP: "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" are saved with the checkboxes are checked.
	Edit Event Notification Profile    profileName=${profile_name}    submit=${False}
	Check Event Exist On Event Notification Profiles Page    ${Plug Inserted in Quareo Port},${Plug Removed from Quareo Port}
    Check Multiple Checkboxes States On Event Notification Profiles Page    events=${Plug Inserted in Quareo Port},${Plug Removed from Quareo Port}    enabled=${True}    selected=${True}  
