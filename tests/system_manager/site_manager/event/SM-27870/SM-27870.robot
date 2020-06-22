*** Settings ***
Resource    ../../../../../resources/constants.robot

Library   ../../../../../py_sources/logigear/setup.py
Library   ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}         
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmEventLogFilterPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmEventNotificationProfilesPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmPriorityEventSettingsPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/events/event_log/EventLogPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/reports/reports/ReportsPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/snmp/SNMPPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py   

Default Tags    Event
Force Tags    SM-27870  

*** Variables ***
${BUILDING_NAME}    Bulk_SM27870
${EVENT}    Cabling Removed from Critical Circuit
${report_event_name}    Report_27870
${restore_file_name}    SM_27870.bak

*** Test Cases ***
(SM-27870-01) Verify that event "Cabling Removed from Critical Circuit" is removed from SM.
    [Setup]    Run Keywords    Set Test Variable    ${profile_event_name}    Profile_27870_01
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Select Main Menu    Administration/Events    Event Notification Profiles
    ...    AND    Delete Event Notification Profile    ${profile_event_name}
    ...    AND    Select Main Menu    Reports
    ...    AND    Delete Report    ${report_event_name}
    
    [Teardown]    Run Keywords   Select Main Menu    Administration/Events    Event Notification Profiles
    ...    AND    Delete Event Notification Profile    ${profile_event_name}
    ...    AND    Select Main Menu    Reports
    ...    AND    Delete Report    ${report_event_name}
    ...    AND    Close Browser   
     
    # Step 1: Go to Administration > Priority Event Settings
    # Step 2: Observe the event in event list
    Select Main Menu    Administration/Events    Priority Event Settings    
    Check Event Not Exist At Priority Event Settings    ${EVENT}   
    
    # Step 3: Go to Administration > Event Notification Profiles
    # Step 4: Add a profile 01, click next until Event list displays
    # Step 5: Observe the event in event list
    Select Main Menu    Administration/Events    Event Notification Profiles
    Add Event Notification Profile    ${profile_event_name}    submit=${FALSE}
    Check Event Not Exist On Event Notification Profiles Page    ${EVENT}           
     
    # Step 6: Go to Administration > Event Log Filters
    # Step 7: Click Add button, notice that "Add Event Log Filter" window displays
    #8. Expand "System Manager Events" tab
    #9. Observe the event in event list
    Select Main Menu    Administration/Events    Event Log Filters        
	Click Add Event Log Filter
	Select Event Log Filter Tab    System Manager Events
	Check Event Not Exist In Add Event Log Filter    ${EVENT}
	Click Event Log Filter Page Cancel Button
	    
    # Step 10: Go to Reports, Add Events > Event Log Details util Select Filters page displays
    # Step 11: Observe the event in Event Type pane
    Select Main Menu    Reports    
    Add Report    Events    Event Log Details    ${report_event_name}    ${report_event_name}
    Check Object Not Exist On Multiple Select Filter    EventType    ${EVENT}

(Bulk-SM-27870-02-04) Verify that SM does not genarate event "Cabling Removed from Critical Circuit" in Event Log with critical circuit.
    [Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Building    name=${BUILDING_NAME}
    
    [Teardown]    Run Keywords    Delete Building    name=${BUILDING_NAME}
    ...    AND    Close Browser    
    
    [Tags]    Sanity
        
        
    #1. Add Building 01/ Floor 01/ Room 01/ 1:1 Rack 001, Rack 002, Rack 003
    ${tree_node_building}=    Add Building    ${SITE_NODE}    ${BUILDING_NAME}
    ${tree_node_floor}=    Add Floor    ${tree_node_building}    Floor 01
    ${tree_node_room}=    Add Room    ${tree_node_floor}    Room 01
    :FOR    ${i}    IN RANGE    1    4
    \    ${temp}=    Add Rack    ${tree_node_room}    Rack ${i}    position=${i}
    \    Set Test Variable    ${tree_node_rack_${i}}    ${temp}
    
    # 2. Add to 1:1 Rack 001:
    # _ RJ-45 Panel 01, 02
    # _ LC Panel 03, 04
    # _ MPO Panel 05, 06
    ${rack_1_panel_1}=    Add Generic Panel    ${tree_node_rack_1}    Panel 01    portType=RJ-45    quantity=2
    ${rack_1_panel_3}=    Add Generic Panel    ${tree_node_rack_1}    Panel 03    portType=LC    quantity=2
    ${rack_1_panel_5}=    Add Generic Panel    ${tree_node_rack_1}    Panel 05    portType=MPO    quantity=2
    
    # 3. Add to 1:2 Rack 002:
    # _ RJ-45 Panel 01
    # _ LC Panel 02
    # _ MPO Panel 03
    # _ Switch 01/ RJ-45 Card 01, LC Card 02, MPO12 Card 03, MPO24 Card 04 (24 ports each card)
    ${rack_2_switch}=    Add Network Equipment    ${tree_node_rack_2}    Switch 01
    
    @{nec_port_types}=    Create List    RJ-45    LC    MPO12    MPO24
    :FOR    ${port_type}    IN    @{nec_port_types}
    \    ${temp}=    Add Network Equipment Component    ${rack_2_switch}    Network Equipment Card    Card ${port_type}    ${port_type}
    \    Set Test Variable    ${card_name_${port_type}}    ${temp}
    
    ${rack_2_panel_1}=    Add Generic Panel    ${tree_node_rack_2}    Panel 01    portType=RJ-45
    ${rack_2_panel_2}=    Add Generic Panel    ${tree_node_rack_2}    Panel 02    portType=LC
    ${rack_2_panel_3}=    Add Generic Panel    ${tree_node_rack_2}    Panel 03    portType=MPO

    # 4. Add to 1:3 Rack 003:
    # _ RJ-45 Panel 01
    # _ LC Panel 02
    # 5. Add to Room:
    # _ RJ-45 Faceplate 01
    # _ LC Faceplate 02
    ${faceplate_1}=    Add Faceplate    ${tree_node_room}    Faceplate 01    RJ-45
    ${faceplate_2}=    Add Faceplate    ${tree_node_room}    Faceplate 02    LC    
    ${rack_3_panel_1}=    Add Generic Panel    ${tree_node_rack_3}    Panel 01    portType=RJ-45
    ${rack_3_panel_2}=    Add Generic Panel    ${tree_node_rack_3}    Panel 02    portType=LC
    
    # 6. Set critical for all port of Panel 01, 03, 05 in 1:1 Rack 001
    # 7. Set critical for all Ports in Card at 1:2 Rack 002
    # 8. Set critical for all port of Panel 01,02 in 1:3 Rack 003
    @{list_edit_item}=    Create List
    ...    ${rack_1_panel_1}    ${rack_1_panel_3}    ${rack_1_panel_5}
    ...    ${card_name_RJ-45}    ${card_name_LC}    ${card_name_MPO12}    ${card_name_MPO24}
    ...    ${rack_3_panel_1}    ${rack_3_panel_2}
    
    :FOR    ${item}    IN    @{list_edit_item}
    \    Edit Port On Content Table    ${item}    all    critical=True
    \    Reload Page
    
    # 9. Create Cabling in 1:1 Rack 001
    # _ Panel 01/ 01 to Panel 02/ 01 (RJ45 -RJ45)
    # _ Panel 03/ 01 to Panel 04/ 01 (LC - LC)
    # _ Panel 05/ 01 to Panel 06/ 01 (MPO12 - MPO12)
    # _ Panel 05/ 02 to Panel 06/ 02 (MPO24 - MPO24)
    # _ Panel 05/ 03 to Panel 04/ 02->05 (MPO12 - 4xLC)
    # _ Panel 05/ 04 to Panel 04/ 06->11 (MPO12 - 6xLC)
    # _ Panel 05/ 05 to Panel 05/ 12->13 (MPO24 - 12xLC)
    Open Cabling Window    ${rack_1_panel_1}
    Create Cabling    Connect    ${rack_1_panel_1}/01    ${tree_node_rack_1}/Panel 02    portsTo=01
    Create Cabling    Connect    ${rack_1_panel_3}/01    ${tree_node_rack_1}/Panel 04    portsTo=01
    Create Cabling    Connect    ${rack_1_panel_5}/01    ${tree_node_rack_1}/Panel 06    MPO12    Mpo12_Mpo12    portsTo=01
    Create Cabling    Connect    ${rack_1_panel_5}/02    ${tree_node_rack_1}/Panel 06    MPO24    Mpo24_Mpo24    portsTo=02
    Create Cabling    Connect    ${rack_1_panel_5}/03    ${tree_node_rack_1}/Panel 04    MPO12    Mpo12_4xLC    1-1,2-2,3-3,4-4    02,03,04,05
    Create Cabling    Connect    ${rack_1_panel_5}/04    ${tree_node_rack_1}/Panel 04    MPO12    Mpo12_6xLC    A1-2,A3-4,A5-6,A7-8,A9-10,A11-12   06,07,08,09,10,11            
    Create Cabling    Connect    ${rack_1_panel_5}/05    ${tree_node_rack_1}/Panel 04    MPO24    Mpo24_12xLC    1-13,2-14   12,13

    # 10. Create Cabling in 1:2 Rack 002:
    # _ Card 01/ 01 to Panel 01/ 01 (RJ45 -RJ45)
    # _ Card 02/ 01 to Panel 02/ 01 (LC - LC)
    # _ Card 03/ 01 to Panel 03/ 01 (MPO12 - MPO12)
    # _ Card 04/ 01 to Panel 03/ 02 (MPO24 - MPO24)
    # _ Card 03/ 02 to Panel 02/ 02->05 (MPO12 - 4xLC)
    # _ Card 03/ 03 to Panel 02/ 06->11 (MPO12 - 6xLC)
    # _ Card 04/ 02 to Panel 02/ 12->13 (MPO24 - 12xLC)

    Create Cabling    Connect    ${card_name_RJ-45}/01    ${rack_2_panel_1}    portsTo=01
    Create Cabling    Connect    ${card_name_LC}/01    ${rack_2_panel_2}    portsTo=01
    Create Cabling    Connect    ${card_name_MPO12}/01    ${rack_2_panel_3}    ${MPO12}    ${Mpo12_Mpo12}    portsTo=01
    Create Cabling    Connect    ${card_name_MPO24}/01    ${rack_2_panel_3}    ${MPO24}    ${Mpo24_Mpo24}    portsTo=02
    Create Cabling    Connect    ${card_name_MPO12}/02    ${rack_2_panel_2}    ${MPO12}    ${Mpo12_4xLC}    1-1,2-2,3-3,4-4    02,03,04,05
    Create Cabling    Connect    ${card_name_MPO24}/02    ${rack_2_panel_2}    ${MPO24}    ${Mpo24_12xLC}    1-13,2-14   12,13

    # 11. Create Cabling 1:3 Rack 003 :
    # _ Panel 01/ 01 to Faceplate 01/ 01
    # _ Panel 02/ 01 to Faceplate 02/ 01

    Create Cabling    Connect    ${rack_3_panel_1}/01    ${faceplate_1}    portsTo=01
    Create Cabling    Connect    ${rack_3_panel_2}/01    ${faceplate_2}    portsTo=01    
    Close Cabling Window

    # 12. Remove all Cable connection
    Remove Cabling By Context Menu On Site Tree    ${tree_node_rack_1}
    Remove Cabling By Context Menu On Site Tree    ${tree_node_rack_2}
    Remove Cabling By Context Menu On Site Tree    ${tree_node_rack_3}

    # 13. Open Events Window window and observe the result
    Open Events Window
    Check Event Not Exist On Event Log Table    ${EVENT}
    Close Event Log
    
(SM-27870-06) Verify that event "Cabling Removed from Critical Circuit" was generated in old version still be displayed in Event Log after restoring DB from previous version to latest version
    [Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Delete Building    name=${BUILDING_NAME}    
    ...    AND    Close Browser
    
    # 1. Prepare machine 1 with previous SM version (8.2 or 9.0)
	# . Prepare machine 2 with latest SM version
    # 3. Launch and log into SM on machine 1
    # 4. Add Building 01/ Floor 01/ Room 01/ 1:1 Rack 001
    # 5. Add to Rack:
    # _ RJ-45 Panel 01, 02
    # _ LC Panel 03, 04
    # _ MPO Panel 05, 06
    # 6. Set critical for all port of Panel 01, 03, 05
    # 7. Create Cabling:
    # _ Panel 01/ 01 to Panel 02/ 01 (RJ45 -RJ45)
    # _ Panel 03/ 01 to Panel 04/ 01 (LC - LC)
    # _ Panel 05/ 01 to Panel 06/ 01 (MPO12 - MPO12)
    # _ Panel 05/ 02 to Panel 06/ 02 (MPO24 - MPO24)
    # _ Panel 05/ 03 to Panel 04/ 02->05 (MPO12 - 4xLC)
    # _ Panel 05/ 04 to Panel 04/ 06->11 (MPO12 - 6xLC)
    # _ Panel 05/ 05 to Panel 05/ 12->13 (MPO24 - 12xLC)
    # 8. Remove all Cabling on step 7 (use remove funtion on Site/Contents or Cabling window)
    # 9. Back up db on machine 1 then restore on machine 2
    # 10. Launch and log into SM on machine 2
    # 11. Open Events Window window and observe the result
    # Event Log still keep old event "Cabling Removed from Critical Circuit" was generated on previous SM after restoring to latest SM
    Restore Database    ${restore_file_name}    ${DIR_FILE_BK}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Open Events Window
    Check Event Exist On Event Log Table    ${EVENT}
    Close Event Log
