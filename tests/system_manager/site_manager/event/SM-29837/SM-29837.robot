*** Settings ***
Resource    ../../../../../resources/constants.robot

Library   ../../../../../py_sources/logigear/setup.py
Library   ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD} 
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/sgmail/login/LoginSgMailPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/sgmail/contents/SgMailPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py       
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmEventLogFilterPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmEventNotificationProfilesPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmPriorityEventSettingsPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/events/event_log/EventLogPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/reports/ReportsDialog${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/reports/memorized_reports/MemorizedReportsPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/reports/report_archive/ReportArchivePage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/reports/reports/ReportsPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/system_manager/AdmEmailServerPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py   

Default Tags    Event 
Force Tags    SM-29837 

*** Variables ***
${EVENT_1}    Unscheduled Patching Change to Critical Circuit
${EVENT_2}    Patching Change to Critical Circuit
${Critical port}    Critical ports in the circuit:
${Port 1:}    Port 1:
${Port 2/Device:}    Port 2/Device:
${Message}    The following connection was added and affects a critical circuit:

*** Test Cases ***
(Bulk-29837-01-02) Verify that event "Unscheduled Patching Change to Critical Circuit" added to SM and "Patching Change to Critical Circuit" is removed from SM..
    [Setup]    Run Keywords    Set Test Variable    ${report_event_name}    Report_29837_1
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Select Main Menu    Reports
    ...    AND    Delete Report    ${report_event_name}
    
    [Teardown]    Run Keywords   Select Main Menu    Reports
    ...    AND    Delete Report    ${report_event_name}
    ...    AND    Close Browser 
     
    # Step 1: Go to Administration > Priority Event Settings
    # Step 2: Observe the event in event list
    Select Main Menu    ${Administration}/Events    Priority Event Settings    
    Check Event Exist At Priority Event Settings    ${EVENT_1}   
    Check Event Not Exist At Priority Event Settings    ${EVENT_2}       

    # Step 3: Go to Administration > Event Notification Profiles
    # Step 4: Add a profile 01, click next until Event list displays
    # Step 5: Observe the event in event list
    Select Main Menu    ${Administration}/Events    Event Notification Profiles
    Add Event Notification Profile    ${report_event_name}    submit=${FALSE}
    Check Event Exist On Event Notification Profiles Page    ${EVENT_1}           
    Check Event Not Exist On Event Notification Profiles Page    ${EVENT_2}    
 
    # Step 6: Go to Administration > Event Log Filters
    # Step 7: Click Add button, notice that "Add Event Log Filter" window displays
    #8. Expand "System Manager Events" tab
    #9. Observe the event in event list
    Select Main Menu    ${Administration}/Events    Event Log Filters        
	Click Add Event Log Filter
	Select Event Log Filter Tab    System Manager Events
	Check Event Exist In Add Event Log Filter    ${EVENT_1}
	Check Event Not Exist In Add Event Log Filter    ${EVENT_2}
	Click Event Log Filter Page Cancel Button
	    
    # Step 10: Go to Reports, Add Events > Event Log Details util Select Filters page displays
    # Step 11: Observe the event in Event Type pane
    Select Main Menu    Reports    
    Add Report    Events    Event Log Details    ${report_event_name}    ${report_event_name}    confirm=${TRUE}
    Check Object Exist On Multiple Select Filter    Event Type    ${EVENT_1}    
    Check Object Not Exist On Multiple Select Filter    Event Type    ${EVENT_2}
    
(SM-29837-03) Verify that user can receive email after create circuit with critical port.
    [Setup]    Run Keywords    Set Test Variable    ${city_name}    SM_29837_3
    ...    AND    Set Test Variable    ${email_server_name}    Email_Server_29837_3
    ...    AND    Set Test Variable    ${campus_name}    Campus 01
    ...    AND    Set Test Variable    ${building_name}    Building 01
    ...    AND    Set Test Variable    ${floor_name}    Floor 01
    ...    AND    Set Test Variable    ${room_name}    Room 01
    ...    AND    Set Test Variable    ${rack_name}    Rack 001
    ...    AND    Set Test Variable    ${panel_name_1}    Panel 01
    ...    AND    Set Test Variable    ${panel_name_2}    Panel 02
    ...    AND    Set Test Variable    ${dir_name}    Server 01
    ...    AND    Set Test Variable    ${email_subject}    Unscheduled Patching Change to Critical Circuit
    ...    AND    Set Test Variable    ${tree_node_room}    ${SITE_NODE}/${city_name}/${campus_name}/${building_name}/${floor_name}/${room_name}
    ...    AND    Set Test Variable    ${tree_node_rack}    ${tree_node_room}/1:1 ${rack_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${city_name}
    ...    AND    Select Main Menu    ${Administration}/System Manager    Email Servers    
    ...    AND    Delete Email Server    ${email_server_name}
    ...    AND    Select Main Menu    subItem=Event Notification Profiles
    ...    AND    Delete Event Notification Profile    ${city_name}

    [Teardown]    Run Keywords    Delete Email    ${email_subject}
    ...    AND    Switch Window    ${site_manager}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${city_name}    
    ...    AND    Select Main Menu    ${Administration}/System Manager    Email Servers    
    ...    AND    Delete Email Server    ${email_server_name}
    ...    AND    Select Main Menu    subItem=Event Notification Profiles
    ...    AND    Delete Event Notification Profile    ${city_name}
    ...    AND    Close Browser

    [Tags]    Sanity
    
    ## Pre-Condition ###
    Select Main Menu    ${Administration}/System Manager    Email Servers
    Add Email Server    ${email_server_name}    ${EMAIL_NAME}    ${EMAIL_SERVER}    
    Select Main Menu    Site Manager  

    # 1. Add City 01/Campus 01/Building 01/Floor 01/Room 01/Rack 001
    # 2. Add Server 01 to Rack 001
    # 3. Add panel 01, Panel 02 to Rack 001
    Add City    ${SITE_NODE}    ${city_name}
    Add Campus    ${SITE_NODE}/${city_name}    ${campus_name}    
    Create Object    ${SITE_NODE}/${city_name}/${campus_name}    ${building_name}    ${floor_name}    ${room_name}    ${rack_name}
    Add Generic Panel    ${tree_node_rack}    ${panel_name_1}    quantity=2
    Add Device In Rack    ${tree_node_rack}    ${dir_name}
    Add Device In Rack Port    ${tree_node_rack}/${dir_name}    01    quantity=12
    
    # 4. Go to Administration > Event Notification Profiles
    # 5. Add a profile 01 with location is City 01 and select event "Unscheduled Patching Change to Critical Circuit"
    Select Main Menu    ${Administration}/Events    Event Notification Profiles
    Add Event Notification Profile    ${city_name}    events=${EVENT_1}    locationPath=${SITE_NODE}/${city_name}
    ...    sendEmail=${True}    emailServer=${email_server_name}    recipients=${EMAIL_NAME}
    
    # 6. Go to Site Manager
    Select Main Menu    Site Manager
    # 7. Create Cabling: Panel 01/01 to Panel 02/01
    Open Cabling Window    ${tree_node_rack}/${panel_name_1}    01
    Create Cabling    Connect    ${tree_node_rack}/${panel_name_1}/01    ${tree_node_rack}/${panel_name_2}    portsTo=01
    Close Cabling Window
    
    # 8. Set critical for Panel 01/01
    Edit Port On Content Table    ${tree_node_rack}/${panel_name_1}    01    critical=${True}

    # 9. Create Patching and uncheck create WO: Panel 01/01 to Server 01/01
    Open Patching Window    ${tree_node_rack}/${panel_name_1}
    Create Patching    patchFrom=${tree_node_rack}/${panel_name_1}    patchTo=${tree_node_rack}/${dir_name}    portsFrom=01    portsTo=01    createWo=no
    
    # 10. Wait until SM send mail to recipients in Event Notification Profiles.
    # 11. Observed result.
    ${site_manager} =    Get Current Tab Alias 
    Open New Tab    ${SGMAIL_URL}
    Login To Sgmail    ${EMAIL_NAME}    ${EMAIL_PASSWORD}
    Check Email Exist    ${email_subject}    ${Message},${Port 1:},01,${panel_name_1},1:1 ${rack_name},${tree_node_room},${Port 2/Device:},01,${dir_name},1:1 ${rack_name},${tree_node_room},${Critical port},${tree_node_rack}/${panel_name_1}/01    300

(SM-29837-04) Verify that user can receive email after create circuit with critical port.
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM_29837_4
    ...    AND    Set Test Variable    ${email_server_name}    Email Server 29837_4
    ...    AND    Set Test Variable    ${floor_name}    Floor 01
    ...    AND    Set Test Variable    ${room_name}    Room 01
    ...    AND    Set Test Variable    ${rack_name}    Rack 001
    ...    AND    Set Test Variable    ${panel_name_1}    Panel 01
    ...    AND    Set Test Variable    ${panel_name_2}    Panel 02
    ...    AND    Set Test Variable    ${switch_name}    Switch 01
    ...    AND    Set Test Variable    ${report_event_name}    Report_29837_4
    ...    AND    Set Test Variable    ${email_subject}    Memorize_Report_29837_4
    ...    AND    Set Test Variable    ${tree_node_room}    ${SITE_NODE}/${building_name}/${floor_name}/${room_name}
    ...    AND    Set Test Variable    ${tree_node_rack}    ${tree_node_room}/1:1 ${rack_name}
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building    ${building_name}    
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Select Main Menu    ${Administration}/System Manager    Email Servers    
    ...    AND    Delete Email Server    ${email_server_name}
    ...    AND    Select Main Menu    Reports
    ...    AND    Delete Report    ${report_event_name}

    [Teardown]    Run Keywords    Delete Building    name=${building_name}    
    ...    AND    Select Main Menu    ${Administration}/System Manager    Email Servers    
    ...    AND    Delete Email Server    ${email_server_name}
    ...    AND    Select Main Menu    Reports
    ...    AND    Delete Report    ${report_event_name}
    ...    AND    Close Browser
    
    ### Pre-Condition ###
    # . Add City 01/Campus 01/Building 01/Floor 01/Room 01/Rack 001
    # . Add MNE/NE to Room 01
    # . Add Faceplate 01to Room 01
    # . Add Panel 01 to Rack 001
    # . Do some Cabling connections between Panel 01 and Faceplate 01 on some ports
    # . Set Critical for Port 01 of Panel 01
    # . Do some Patching connections between MNE/NE and Panel
    # . Create a """"Unscheduled Patching Change to Critical Circuit"""" report with default value.
    Select Main Menu    ${Administration}/System Manager    Email Servers
    Add Email Server    ${email_server_name}    ${EMAIL_NAME}    ${EMAIL_SERVER}    
    Select Main Menu    Site Manager
    Add Floor    ${SITE_NODE}/${building_name}    ${floor_name}
    Add Room    ${SITE_NODE}/${building_name}/${floor_name}    ${room_name}
    Add Rack    ${SITE_NODE}/${building_name}/${floor_name}/${room_name}    ${rack_name}
    Add Generic Panel    ${tree_node_rack}    ${panel_name_1}    quantity=2
    Add Network Equipment    ${tree_node_rack}    ${switch_name}
    Add Network Equipment Port    ${tree_node_rack}/${switch_name}    01    quantity=12
    Open Cabling Window    ${tree_node_rack}/${panel_name_1}    01
    Create Cabling    Connect    ${tree_node_rack}/${panel_name_1}/01    ${tree_node_rack}/${panel_name_2}    portsTo=01
    Close Cabling Window
    Edit Port On Content Table    ${tree_node_rack}/${panel_name_1}    01    critical=True
    Open Patching Window    ${tree_node_rack}/${panel_name_1}
    Create Patching    patchFrom=${tree_node_rack}/${panel_name_1}    patchTo=${tree_node_rack}/${switch_name}    portsFrom=01    portsTo=01    createWo=no
    Select Main Menu    Reports    
    Add Report    Events    Event Log Details    ${report_event_name}    ${report_event_name}    confirm=${FALSE}
    
    # 1. Go to Report tab
    # 2. Select "Unscheduled Patching Change to Critical Circuit" pre-conditional report on Reports page
    # 3. Click on View button
    View Report    ${report_event_name}    
    
    # 4. On Select filter page, select as
    # + Location: Select City 01
    # + Event Type: Unscheduled Patching Change to Critical Circuit
    # 5. Click on View button on Edit filter page
    Select Filter For Report    addMultiSelectFilter=Event Type:${EVENT_1}    selectLocationType=Click    treeNode=${tree_node_rack}    clickViewBtn=${True}
   
    # 6. Observe the result
    Check Event Report Exist    ${room_name},1,1,${rack_name},${panel_name_1},${EVENT_1}    
    ...    ${Message},${Port 1:},01,${panel_name_1},1:1 ${rack_name},${tree_node_room},${Port 2/Device:},01,${switch_name},1:1 ${rack_name},${tree_node_room},${Critical port},${tree_node_rack}/${panel_name_1}/01,${tree_node_rack}/${panel_name_1}/01
    
    # 7. Download the report
    Print Report
    ${site_manager} =    Get Current Tab Alias 
    Open New Tab    ${DOWNLOAD_URL}
    ${excel_file_name} =    Get Print Report File
    Close Current Tab
    Switch Window    ${site_manager}
    
    # 8. Observe the result
    Check Download File Exist    ${excel_file_name}   
    
    # 9. Send email about the report
    Send Email Report    ${email_server_name}    ${EMAIL_NAME}    ${email_subject}    ${email_subject}

    # 10. Observe the result
    Open New Tab    ${SGMAIL_URL}
    Login To Sgmail    ${EMAIL_NAME}    ${EMAIL_PASSWORD}
    Check Email Exist    ${email_subject}    
    ${report_email_link} =    Get Report Link In Email
    Delete Email    ${email_subject} 
    Open New Tab    ${report_email_link}
    Login    ${USERNAME}    ${PASSWORD}
    Check Event Report Exist    ${room_name},1,1,${rack_name},${panel_name_1},${EVENT_1}    
    ...    ${Message},${Port 1:},01,${panel_name_1},1:1 ${rack_name},${tree_node_room},${Port 2/Device:},01,${switch_name},1:1 ${rack_name},${tree_node_room},${Critical port},${tree_node_rack}/${panel_name_1}/01,${tree_node_rack}/${panel_name_1}/01
    Close Current Tab
    Switch Window    ${site_manager}

    # 11. Do memorize report
    Create Memorize Report    ${report_event_name}    ${report_event_name}    
    View Memorized Report    ${report_event_name}
    
    # 12. Observe the result
    Check Event Report Exist    ${room_name},1,1,${rack_name},${panel_name_1},${EVENT_1}    
    ...    ${Message},${Port 1:},01,${panel_name_1},1:1 ${rack_name},${tree_node_room},${Port 2/Device:},01,${switch_name},1:1 ${rack_name},${tree_node_room},${Critical port},${tree_node_rack}/${panel_name_1}/01,${tree_node_rack}/${panel_name_1}/01
 