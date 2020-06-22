*** Settings ***
Resource    ../../../../../resources/constants.robot

Library   ../../../../../py_sources/logigear/setup.py  
Library   ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py       
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py 
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/snmp/SNMPPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/reports/reports/ReportsPage${PLATFORM}.py    	
Library   ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/user_defined_fields/AdmPortFieldsPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py    

Default Tags    Reports
Force Tags    SM-29576

*** Variables ***
${CAMPUS_NAME}    Campus 01
${BUILDING_NAME}    Bulk_SM29576
${FLOOR_NAME}    Floor 01 
${ROOM_NAME}    Room 01
${RACK_GROUP_NAME}    Rack Group 01
${RACK_NAME}    Rack 001
${SWITCH_NAME}    Switch 01
${SWITCH_NAME_2}    Switch 02
${NE_NAME}    NE 01
${CARD_NAME_1}    Card 01
${CARD_NAME_2}    Card 02
${FACEPLATE_NAME}    Faceplate 01
${PANEL_NAME}    Panel 01
${PANEL_NAME_2}    Panel 02
${PANEL_NAME_3}    Panel 03
${RESTORE_FILE_NAME}    DB SM-29576.bak
${SWITCH_NAME_3}    Blade 1 BX630 F1R5 cabina 1
${SWITCH_NAME_4}    MXOCCSWT03_A
${IP_ADDRESS}    10.5.4.7
${REPORT_TYPE}    Network Equipment Port Information
${REPORT_DESCRIPTION}    Use this report to see information about network equipment and managed network equipment ports.

*** Test Cases ***
(Bulk_SM-29576-01-03)_Verify there is a new "Network Equipment Port Information" report and its description in Properties report, the UI on Select Filters page of Managed/Non-Managed Network Equipment Port" report
    [Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Building     name=${BUILDING_NAME}
    
    [Teardown]    Run Keywords   Select Main Menu    ${Reports}
    ...    AND    Delete Report    ${report_name}
    ...    AND    Close Browser
    
    ${report_name}    Set Variable    SM-29576-03

    # Step 1: Click on "Reports" tab
    # Step 2: Click on (+) button, then select "All"
    # Step 3: Observe the result
    # . Verify there is a new report named "Network Equipment Port Information"
    # . Verity the description should be "Use this report to see detailed information of the ports in Managed/Non-Managed Network Equipments."
    Select Main Menu    ${Reports}
    Select Category Report To Add    All
    Check Report Category Exist    All Report    ${REPORT_TYPE}    ${REPORT_DESCRIPTION}
    
    # Step 4: Back to the "Reports" page, and click on (+) button
    # Step 5: Select "Properties" report in the category
    # Step 6: Observe the result
    # . Verify there is a new report named "Network Equipment Port Information"
    # . Verity the description should be "Use this report to see detailed information of the ports in Managed/Non-Managed Network Equipments."
    Select Main Menu    ${Reports}
    Select Category Report To Add    Properties
    Check Report Category Exist    Properties Report    ${REPORT_TYPE}    ${REPORT_DESCRIPTION}
    
    # Step 2: Go to the "Reports" page, and click on (+) button
    # Step 3: Select "Properties" report in the category
    # Step 4: Select "Network Equipment Port Information" report
    # Step 5: Click on 'Next' button (Check mark button) on Edit Layout page
    # Step 6: Enter name and description then click on OK button (Check mark button) on current page
    # Step 7: Select "Yes, generated the report" on 'Custom Report Created' pop-up
    Select Main Menu    ${Reports}
    Delete Report    ${report_name}
    Add Report    All    ${REPORT_TYPE}    ${report_name}    ${report_description}    confirm=${TRUE}
    # Step 8: Observe "Select Filters" page
    #    Verify the "Select Filters" page displays on following filters: 
    #    _Location: to select or multi-select locations, all the way to the Room level.
    #    _Link Status: All/Up/Down
    #    _Uplink: All/Yes/No
    #    _Patching Status: Available/Available-Pending/In Use/In Use-Pending
    ${link_status}    Set Variable    All,Up,Down
    ${uplink}    Set Variable    All,Yes,No
    ${patching_status}    Set Variable    Available,Available - Pending,In Use,In Use - Pending
    
    Check Object Exist On Multiple Select Filter    Patching Status    ${patching_status}
	Check Object Exist On Combo Box Filter    Uplink    ${uplink}
	Check Object Exist On Combo Box Filter    Link Status    ${link_status}
	
(SM-29576-05)_Verify user can generate "Network Equipment Port Information" report for MNE/NE with default columns in Room
    [Setup]    Run Keywords    Set Test Variable    ${city_name}    City_SM29576_05
    ...    AND    Open SM Login Page    
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${city_name}
    
    [Teardown]    Run Keywords    Select Main Menu    ${Reports}
    ...    AND    Delete Report    ${report_name}
    ...    AND    Select Main Menu    ${Site Manager}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${city_name}   
    ...    AND    Close Browser
       
    ${report_name}    Set Variable    SM-29576-05
    ${report_description}    Set Variable    Check report page.
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}
    ${tree_node_rack_report}    Set Variable    ${SITE_NODE} ${SLASH} ${city_name} ${SLASH} ${CAMPUS_NAME} ${SLASH} ${BUILDING_NAME} ${SLASH} ${FLOOR_NAME} ${SLASH} ${ROOM_NAME} ${SLASH} 1:1 ${RACK_NAME}    
    
    # Add City 01/Campus 01/Building 01/Floor 01/Room 01/Rack 001
    Add City    ${SITE_NODE}    ${city_name}
    Add Campus    ${SITE_NODE}/${city_name}    ${CAMPUS_NAME}    
    Add Building    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}    ${BUILDING_NAME}
    Add Floor    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}    position=1
    
    # Add MNE/NE to Room 01 with different port types as RJ-45, LC and MPO
    Add Network Equipment    ${tree_node_rack}    ${SWITCH_NAME}
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_NAME}    01    portType=${RJ-45}
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_NAME}    02    portType=${LC}
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_NAME}    03    portType=${MPO12}
    # Add some Faceplates to Room
    Add Faceplate    ${tree_node_room}    ${FACEPLATE_NAME}    
    # Add some panels with different ports as RJ-45, LC and MPO to Rack 001
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME}    portType=${RJ-45}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_2}    portType=${LC}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_3}    portType=${MPO}
    
    # Do some Cabling connections between MNE/NE and Faceplates on some ports
    Open Cabling Window    ${tree_node_rack}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${tree_node_rack}/${PANEL_NAME}/01    cableTo=${tree_node_room}/${FACEPLATE_NAME}
    ...    portsTo=01
    Close Cabling Window
    
    # Do some Patching connections between MNE/NE and Panels
    Open Patching Window    ${tree_node_rack}/${SWITCH_NAME}    01
    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME}    patchTo=${tree_node_rack}/${PANEL_NAME}
    ...    portsFrom=01    portsTo=01    clickNext=${False}
    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME}    patchTo=${tree_node_rack}/${PANEL_NAME_2}
    ...    portsFrom=02    portsTo=01    clickNext=${False}
    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME}    patchTo=${tree_node_rack}/${PANEL_NAME_3}
    ...    portsFrom=03    portsTo=01    createWo=no
    
    # Create a "Network Equipment Port Information" report with default value.
    Select Main Menu    ${Reports}
    Delete Report    ${report_name}
    Add Report    All    ${REPORT_TYPE}    ${report_name}    ${report_description}
    
    # Step 1: Go to Report tab
    # Step 2: Select "Network Equipment Port Information" pre-conditional report on Reports page
    # Step 3: Click on View button
    # Step 4: On Select filter page, select as
    # + Location: Select NE
    # + Link Status: All
    # + Uplink: All
    # + Patching Status: All
    # Step 5: Click on View button on Edit filter page
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_rack}/${SWITCH_NAME}    clickViewBtn=${True}
	Sort View Report Table By Column Name    Location    typeSort=desc
	Sort View Report Table By Column Name    Location    typeSort=asc
    # Step 6: Observe the result
    # Step 7: Download the report
    # Step 8: Observe the result
    ${headers}    Set Variable    Location,Equipment,Port Name,Port Type,Port Connection,Link Status
	${values_list}    Create List
	...    ${tree_node_rack_report},${SWITCH_NAME},01,RJ-45,Yes (patched), 
	...    ${tree_node_rack_report},${SWITCH_NAME},02 A,LC,Yes (patched), 
	...    ${tree_node_rack_report},${SWITCH_NAME},02 B,LC,Yes (patched), 
	...    ${tree_node_rack_report},${SWITCH_NAME},03,MPO12,Yes (patched), 
    ${rows_list}    Create List    1    2    3    4

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]   

(SM-29576-06)_Verify user can generate "Network Equipment Port Information" report for MNE/NE with default columns in Rack
    [Setup]    Run Keywords    Set Test Variable    ${city_name}    City_SM29576_06
    ...    AND    Open SM Login Page 
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${city_name}
    
    [Teardown]    Run Keywords    Select Main Menu    ${Reports}
    ...    AND    Delete Report    ${report_name}
    ...    AND    Select Main Menu    ${Site Manager}        
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${city_name}   
    ...    AND    Close Browser
     
    ${report_name}    Set Variable    SM-29576-06
    ${ip_address}    Set Variable    10.5.4.7
    ${report_description}    Set Variable    Check report page.
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}
    ${tree_node_rack_report}    Set Variable    ${SITE_NODE} ${SLASH} ${city_name} ${SLASH} ${CAMPUS_NAME} ${SLASH} ${BUILDING_NAME} ${SLASH} ${FLOOR_NAME} ${SLASH} ${ROOM_NAME} ${SLASH} 1:1 ${RACK_NAME}    
    
    # Add City 01/Campus 01/Building 01/Floor 01/Room 01/Rack 001
    Add City    ${SITE_NODE}    ${city_name}
    Add Campus    ${SITE_NODE}/${city_name}    ${CAMPUS_NAME}    
    Add Building    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}    ${BUILDING_NAME}
    Add Floor    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}    position=1
    
    # Add some Faceplates to Room
    Add Faceplate    ${tree_node_room}    ${FACEPLATE_NAME}    
    # Add MNE/NE to Rack 001 with different port types as RJ-45, LC and MPO
    Add Managed Switch    ${tree_node_rack}    ${SWITCH_NAME}    ${ip_address}    IPv4    ${False}
    Synchronize Managed Switch    ${tree_node_rack}/${SWITCH_NAME}    
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${ip_address}
    # Open Synchronize Status Window
    # Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}   
    # Add some panels with different ports as RJ-45, LC and MPO to Rack 001
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME}    portType=${RJ-45}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_2}    portType=${LC}
    
    # Do some Cabling connections between MNE/NE and Faceplates on some ports
    Open Cabling Window    ${tree_node_rack}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${tree_node_rack}/${PANEL_NAME}/01    cableTo=${tree_node_room}/${FACEPLATE_NAME}
    ...    portsTo=01
    Close Cabling Window
    
    # For MNE, do patching/un-patching connection on some ports, but not complete WOes
    Open Patching Window    ${tree_node_rack}/${SWITCH_NAME}/Card 02    01
    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME}/Card 02    patchTo=${tree_node_rack}/${PANEL_NAME}
    ...    portsFrom=01    portsTo=01    clickNext=${False}
    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME}/Card 03/GBIC Slot 21    patchTo=${tree_node_rack}/${PANEL_NAME_2}
    ...    portsFrom=01    portsTo=01    createWo=yes   clickNext=yes
    Create Work Order
    
    Open Patching Window    ${tree_node_rack}/${SWITCH_NAME}/Card 02    02
    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME}/Card 02    patchTo=${tree_node_rack}/${PANEL_NAME}
    ...    portsFrom=02    portsTo=02    clickNext=${False}
    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME}/Card 03/GBIC Slot 22    patchTo=${tree_node_rack}/${PANEL_NAME_2}
    ...    portsFrom=01    portsTo=02    createWo=no
    
    # Create a "Network Equipment Port Information" report with default value.
    Select Main Menu    ${Reports}
    Delete Report    ${report_name}
    Add Report    All    ${REPORT_TYPE}    ${report_name}    ${report_description}
    
    # Step 1: Go to Report tab
    # Step 2: Select "Network Equipment Port Information" pre-conditional report on Reports page
    # Step 3: Click on View button
    # Step 4: On Select filter page, select as
    # + Location: Select NE
    # + Link Status: All
    # + Uplink: All
    # + Patching Status: All
    # Step 5: Click on View button on Edit filter page
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_rack}/${SWITCH_NAME}    clickViewBtn=${True}
	Sort View Report Table By Column Name    Location    typeSort=desc
	Sort View Report Table By Column Name    Location    typeSort=asc
    # Step 6: Observe the result
    ${headers}    Set Variable    Location,Equipment,Port Name,Port Type,Port Connection
	${values_list}    Create List
	...    ${tree_node_rack_report},${SWITCH_NAME},01,RJ-45,No
	...    ${tree_node_rack_report},${SWITCH_NAME},02,RJ-45,Yes (patched)
	...    ${tree_node_rack_report},${SWITCH_NAME},03,RJ-45,No
	...    ${tree_node_rack_report},${SWITCH_NAME},01,SC Duplex,No
	...    ${tree_node_rack_report},${SWITCH_NAME},01,SC Duplex,No
	...    ${tree_node_rack_report},${SWITCH_NAME},01,RJ-45,No
	...    ${tree_node_rack_report},${SWITCH_NAME},02,RJ-45,No
	...    ${tree_node_rack_report},${SWITCH_NAME},03,RJ-45,No	
	...    ${tree_node_rack_report},${SWITCH_NAME},01,SC Duplex,No  
	...    ${tree_node_rack_report},${SWITCH_NAME},01 A,SC Duplex,Yes (patched)
	...    ${tree_node_rack_report},${SWITCH_NAME},01 B,SC Duplex,Yes (patched)
	...    ${tree_node_rack_report},${SWITCH_NAME},23,RJ-45,No
	...    ${tree_node_rack_report},${SWITCH_NAME},24,RJ-45,No
    ${rows_list}    Create List    1    2    3    21    22    23    24    25    43    44    45    188    189  

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]   

(SM-29576-07)_Verify user can generate "Network Equipment Port Information" report for MNE/NE with adding some columns (not in Groups) to the contain
    [Setup]    Run Keywords    Set Test Variable    ${city_name}    City_SM29576_07
    ...    AND    Open SM Login Page 
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${city_name}
    
    [Teardown]    Run Keywords    Select Main Menu    ${Reports}
    ...    AND    Delete Report    ${report_name}
    ...    AND    Select Main Menu    ${Site Manager}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${city_name}   
    ...    AND    Close Browser
      
    ${report_name}    Set Variable    SM-29576-07
    ${report_description}    Set Variable    Check report page.
    ${ip_address}    Set Variable    10.5.1.108
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}  
    ${tree_node_rack_report}    Set Variable    ${SITE_NODE} ${SLASH} ${city_name} ${SLASH} ${CAMPUS_NAME} ${SLASH} ${BUILDING_NAME} ${SLASH} ${FLOOR_NAME} ${SLASH} ${ROOM_NAME} ${SLASH} ${RACK_GROUP_NAME} ${SLASH} 1:1 ${RACK_NAME}  
    
    # Add City 01/Campus 01/Building 01/Floor 01
    # Add Room 01 with Zone mode as Rack Groups 01
    # Add Rack 001 to Rack Groups 01
    Add City    ${SITE_NODE}    ${city_name}
    Add Campus    ${SITE_NODE}/${city_name}    ${CAMPUS_NAME}    
    Add Building    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}    ${BUILDING_NAME}
    Add Floor    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}    ${ROOM_NAME}    Rack Groups
    Add Rack Group    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_GROUP_NAME}
    Add Rack    ${SITE_NODE}/${city_name}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}    ${RACK_NAME}    position=1    waitForCreate=${False}
    
    # Add NE and MNE with having some ports in Card and GBIC slot to Rack 001 
    Add Managed Switch    ${tree_node_rack}    ${SWITCH_NAME}    ${ip_address}    IPv4    ${False}
    Synchronize Managed Switch    ${tree_node_rack}/${SWITCH_NAME}
    Add Network Equipment    ${tree_node_rack}    ${NE_NAME} 
    Add Network Equipment Port    ${tree_node_rack}/${NE_NAME}    01    portType=${MPO12}
    # Add some panels with different ports as RJ-45, LC and MPO to Rack 001
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME}    portType=${RJ-45}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_2}    portType=${LC}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_3}    portType=${MPO}
    
    # Do some Patching/Cabling connections between MNE/NE and Panels
    # For MNE, do patching/un-patching connection on some ports, but not complete WOes   
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME}    01
    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME}    patchTo=${tree_node_rack}/${PANEL_NAME}
    ...    portsFrom=11    portsTo=01    clickNext=${False}
    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME}    patchTo=${tree_node_rack}/${PANEL_NAME_2}
    ...    portsFrom=01    portsTo=01
    Create Work Order    

    Open Patching Window    ${tree_node_rack}/${NE_NAME}    01
    Create Patching    patchFrom=${tree_node_rack}/${NE_NAME}    patchTo=${tree_node_rack}/${PANEL_NAME_3}
    ...    portsFrom=01    portsTo=01    createWo=no

    # Step 1: Go to Report tab
    # Step 2: Select "Network Equipment Port Information" pre-conditional report on Reports page
    # Step 3: Click on View button
    # Step 4: On Select filter page, select as
    # + Location: Select NE
    # + Link Status: All
    # + Uplink: All
    # + Patching Status: All
    Select Main Menu    ${Reports}
    Delete Report    ${report_name}
    Add Report    All    ${REPORT_TYPE}    ${report_name}    ${report_description}
    # Step 5: Click on View button on Edit filter page
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
	Sort View Report Table By Column Name    Location    typeSort=desc
	Sort View Report Table By Column Name    Location    typeSort=asc
    # Step 6: Observe the result
    
    ${headers}    Set Variable    Location,Equipment,Port Name,Port Type,Port Connection
	${values_list}    Create List
	...    ${tree_node_rack_report},${NE_NAME},01,MPO12,Yes (patched)	
	...    ${tree_node_rack_report},${SWITCH_NAME},01,LC,No
	...    ${tree_node_rack_report},${SWITCH_NAME},02,LC,No
	...    ${tree_node_rack_report},${SWITCH_NAME},11,RJ-45,No
	...    ${tree_node_rack_report},${SWITCH_NAME},12,RJ-45,No
	...    ${tree_node_rack_report},${SWITCH_NAME},13,RJ-45,No	
	
    ${rows_list}    Create List    1    2    3    12    13    14

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]   

(Bulk_SM-29576-02-04-12)_Verify User Can Generate Network Equipment Port Information Report For MNE In Room/Rack With Adding The Fields In Port Fields Section
    [Setup]    Run Keywords    Set Test Variable    ${port_field_label_1}    Test 1    
    ...    AND    Set Test Variable    ${port_field_label_2}    Test 2    
    ...    AND    Set Test Variable    ${port_field_label_3}    Test 3
    ...    AND    Set Test Variable    ${port_field_label_4}    Test 4
    ...    AND    Set Test Variable    ${port_field_label_5}    Test 5    
    ...    AND    Set Test Variable    ${building_name}    Building_SM_29576_12
    ...    AND    Set Test Variable    ${ip_address}    10.5.1.108
    ...    AND    Set Test Variable    ${report_name}   SM-29576-12   
    ...    AND    Delete Building     name=${building_name}  
    ...    AND    Add New Building    ${building_name}    
    ...    AND    Open SM Login Page   
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
          
    [Teardown]    Run Keywords    Select Main Menu    ${Reports}   
    ...    AND    Delete Report    ${report_name}
    ...    AND    Select Main Menu    ${Site Manager}
    ...    AND    Delete Building     name=${building_name}  
    ...    AND    Close Browser
        
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}
    ${tree_node_switch_1}    Set Variable    ${tree_node_room}/${SWITCH_NAME}
    ${tree_node_switch_3}    Set Variable    ${tree_node_rack}/${SWITCH_NAME_3}   
    ${tree_node_room_report}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_report}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME} ${SLASH} ${ROOM_NAME} ${SLASH} 1:1 ${RACK_NAME}  
    
    # . Go to Administration > Port Fields page
	# . Check all options on the page, and input values for 5 Port Field labels
    Select Main Menu    ${Administration}    Port Fields	
    Create Port Fields Data    ${TRUE}    ${TRUE}    ${TRUE}    ${TRUE}    ${TRUE}    ${TRUE}    ${TRUE}    ${TRUE}    ${TRUE}    ${TRUE}
    ...    ${port_field_label_1}    ${port_field_label_2}    ${port_field_label_3}    ${port_field_label_4}    ${port_field_label_5}
    
    ### TC_SM-29576-02_Verify the UI of Edit layout page of Managed/Non-Managed Network Equipment Port" report
    # . Go to the "Reports" page, and click on (+) button
    # . Select "Properties" report in the category
    # 1. Select "Network Equipment Port Information" report 
    Select Main Menu    ${Reports}
    Select Category Report To Add    Properties    ${REPORT_TYPE}   
    
	# 2. Observe Edit Layout page
    # Step 2: Verify user should see "Header and Footer" and "Data" on the left board as following:
	# 3. Click on following fields to expand port properties groups
	# 4. Observe the result
	# *Step 4: Verify the port properties groups should be shown as below	
	Check Layout Items Not Exist    ContentLeft    Port Name,Port Type,Port Configuration,Service 01,Service 02,Service 03,Service 04,Service 05,Service 06,Service 07,Service 08,Service 09,Service 10,Service 11,Service 12,Port Connection,Patching Status,Critical,Not Available,Reserved,Service Designation,Service Designation,Route Designation,Uplink,Unique ID,Link Status,VLAN,Voice VLAN,Description,PoE Type,PoE Port Status,PoE Allocated (W),PoE Consumption (W),${port_field_label_5},${port_field_label_4},${port_field_label_3},${port_field_label_2},${port_field_label_1},Cord Color,Cord Type,Cord Length,Service Ticket ID,Connection ID,Connected Equipment Location,Connected Equipment IP Address,Connected Equipment MAC Address,Device Type,Connected Equipment Type,Connected Equipment Name,Location,Equipment    
    ${source_panel_list}    Create List    HeaderFooterLeft    ContentLeft    Header    Content
    ${items_list}    Create List
    ...    Custom Text
    ...    City,Campus,Building,Room,Rack Group,Rack,Card,GBIC,Configuration->Port Configuration,Configuration->Service 01,Configuration->Service 02,Configuration->Service 03,Configuration->Service 04,Configuration->Service 05,Configuration->Service 06,Configuration->Service 07,Configuration->Service 08,Configuration->Service 09,Configuration->Service 10,Configuration->Service 11,Configuration->Service 12,Status->Patching Status,Status->Critical,Status->Not Available,Status->Reserved,Status->Service Designation,Status->Service Designation,Status->Route Designation,Status->Uplink,Details->Unique ID,Details->VLAN,Details->Voice VLAN,Details->Description,PoE->PoE Type,PoE->PoE Port Status,PoE->PoE Allocated (W),PoE->PoE Consumption (W),Port Fields->${port_field_label_5},Port Fields->${port_field_label_4},Port Fields->${port_field_label_3},Port Fields->${port_field_label_2},Port Fields->${port_field_label_1},Port Fields->Cord Color,Port Fields->Cord Type,Port Fields->Cord Length,Port Fields->Service Ticket ID,Port Fields->Connection ID,Connected Equipment/Devices->Connected Equipment Location,Connected Equipment/Devices->Connected Equipment IP Address,Connected Equipment/Devices->Connected Equipment MAC Address,Connected Equipment/Devices->Device Type,Connected Equipment/Devices->Connected Equipment Type,Connected Equipment/Devices->Connected Equipment Name
	...    Report Title,Patching Status,Uplink,Link Status,Location,Timestamp
	...    Location,Equipment,Port Name,Port Type,Port Connection,Link Status
    :FOR    ${i}    IN RANGE    0    len(${source_panel_list})    	         
	\   Check Layout Items Exist    ${source_panel_list}[${i}]    ${items_list}[${i}]

	# 5. Click again on the above fields
	# 6. Observe the result
	# Step 6: Verify they should be collapsed when clicking on the headers again
    Collapse Layout Items On Content Left    Port Fields,Connected Equipment/Devices,PoE,Details,Status,Configuration    
    Check Layout Items Not Exist    ContentLeft    Port Name,Port Type,Port Configuration,Service 01,Service 02,Service 03,Service 04,Service 05,Service 06,Service 07,Service 08,Service 09,Service 10,Service 11,Service 12,Port Connection,Patching Status,Critical,Not Available,Reserved,Service Designation,Service Designation,Route Designation,Uplink,Unique ID,Link Status,VLAN,Voice VLAN,Description,PoE Type,PoE Port Status,PoE Allocated (W),PoE Consumption (W),${port_field_label_5},${port_field_label_4},${port_field_label_3},${port_field_label_2},${port_field_label_1},Cord Color,Cord Type,Cord Length,Service Ticket ID,Connection ID,Connected Equipment Location,Connected Equipment IP Address,Connected Equipment MAC Address,Device Type,Connected Equipment Type,Connected Equipment Name,Location,Equipment
        
	# 7. Expand all then drag all fields to body on the right side
	# 8. Observe the result
	# . Verify the following headers could not be dragged to Data contain
	# Information
	# Configuration
	# Status
	# Details
	# PoE
	# Port Fields
	# Connected Equipment/Devices
	# . Verify the rest of items could be dragged to Data contain    
    Edit Layout Reports    ContentLeft    Content    Port Fields->${port_field_label_5},Port Fields->${port_field_label_4}  Link Status
    Check Layout Items Not Exist    ContentLeft    Port Fields->${port_field_label_5},Port Fields->${port_field_label_4}
    Check Layout Items Exist    Content    ${port_field_label_5},${port_field_label_4}       		
        
	# 9. Drag some fields back to Data board on the left side from body	
	# 10. Observe the result
	Edit Layout Reports    Content    ContentLeft    Port Connection,Link Status    Room
	Check Layout Items Not Exist    Content    Port Connection,Link Status
	Check Layout Items Exist    ContentLeft    Status->Port Connection,Details->Link Status
            
	# 11. Click on (x) icon on some fields from body    
    # 12. Observe the result    
    # . User should be able to move the defined field from body back to data board on the left side by dragging action or clicking on x icon
    # . The field should be moved back to correct location in group        
    Remove Layout Items    Content    Location,Equipment,Port Name,Port Type
    Check Layout Items Not Exist    Content    Location,Equipment,Port Name,Port Type
    Check Layout Items Exist    ContentLeft    Location,Equipment,Information->Port Name,Information->Port Type 
     
    ### TC_SM-29576-12_Verify user can generate  "Network Equipment Port Information" report for MNE in Room/Rack with adding the fields in Port Fields section
    # . Create a "Network Equipment Port Information" report
	# . On Edit layout page, add more fields to the contain of report as below:
	# Connection ID
	# Service Ticket ID
	# Cord Length
	# Cord Type
	# Cord Color
	# Port Field 1 Label
	# Port Field 2 Label
	# Port Field 3 Label
	# Port Field 4 Label
	# Port Field 5 Label	
    Select Main Menu    ${Reports}   
    Delete Report    ${report_name}
    Add Report    All    ${REPORT_TYPE}    ${report_name}    editLayout=${True}    sourcePane=ContentLeft    destinationPane=Content
    ...    items=Port Fields->${port_field_label_5},Port Fields->${port_field_label_4},Port Fields->${port_field_label_3},Port Fields->${port_field_label_2},Port Fields->${port_field_label_1},Port Fields->Cord Color,Port Fields->Cord Type,Port Fields->Cord Length,Port Fields->Service Ticket ID,Port Fields->Connection ID
    ...    destinationItem=Link Status   	
	    
	# # . Add some NE, MNE to Room 	
	Select Main Menu    ${Site Manager}
	Add Floor     ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
	Add Room     ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}          
	Add Network Equipment    ${tree_node_room}    ${SWITCH_NAME}
	Add Network Equipment Port    treeNode=${tree_node_switch_1}    name=01    quantity=6	   
    
    Add Rack    ${tree_node_room}    ${RACK_NAME}    
    Add Managed Switch   ${tree_node_rack}    ${SWITCH_NAME_3}    ${ip_address}
    Synchronize Managed Switch    ${tree_node_switch_3}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME_3}    ${ip_address}    

    # . Open properties of some ports with different port types (RJ-45, LC and MPO ports) then set Port fields values for these ports      
    ${port_type_list}    Create List    ${RJ-45}    ${LC}    ${MPO12}    ${MPO24}    ${SC_DUPLEX}
    ${edit_port_list}    Create List    01    02    03    04    05
    :FOR    ${i}    IN RANGE    0    len(${port_type_list})  	         
	\    Edit Port On Content Table    treeNode=${tree_node_switch_1}    name=${edit_port_list}[${i}]    portType=${port_type_list}[${i}]    
    ...   connectionId=${i+1}    serviceTicketId=${i+2}    cordLength=${i+3}    cordType=${i+4}    cordColor=${i+5}    portField1=${i+6}
    ...   portField2=${i+7}    portField3=${i+8}    portField4=${i+9}    portField5=${i+10}
    \    Wait For Property On Properties Pane    Cord Color    ${i+5}
    
    :FOR    ${i}    IN RANGE    0    len(${port_type_list})
    \    Edit Port On Content Table    treeNode=${tree_node_switch_3}    name=${edit_port_list}[${i}]    portType=${port_type_list}[${i}]    
    ...   connectionId=${i+11}    serviceTicketId=${i+12}    cordLength=${i+13}    cordType=${i+14}    cordColor=${i+15}    portField1=${i+16}
    ...   portField2=${i+17}    portField3=${i+18}    portField4=${i+19}    portField5=${i+20}
    \    Wait For Property On Properties Pane    Cord Color    ${i+15}

    # 1. Go to Report tab
	# 2. Select "Network Equipment Port Information" pre-conditional report on Reports page
	# 3. Click on View button
	# 4. On Select filter page, select as
	# + Location: Select Room
	# + Link Status: All
	# + Uplink: All
	# + Patching Status: All
	# 5. Click on View button on Edit filter page
	Select Main Menu    ${Reports}   
    View Report    ${report_name}
	Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
	        
	# 6. Observe the result	 
	# 7. Repeat test cases for NE and MNE with Location is Rack
	${headers}    Set Variable    Location,Equipment,Port Name,Port Type,Port Connection,Connection ID,Service Ticket ID,Cord Length,Cord Type,Cord Color,${port_field_label_1},${port_field_label_2},${port_field_label_3},${port_field_label_4},${port_field_label_5}
	${values_list}    Create List
	...    ${tree_node_room_report},${SWITCH_NAME},01,${RJ-45},No,1,2,3,4,5,6,7,8,9,10
	...    ${tree_node_room_report},${SWITCH_NAME},02,${LC},No,2,3,4,5,6,7,8,9,10,11
	...    ${tree_node_room_report},${SWITCH_NAME},03,${MPO12},No,3,4,5,6,7,8,9,10,11,12
	...    ${tree_node_room_report},${SWITCH_NAME},04,${MPO24},No,4,5,6,7,8,9,10,11,12,13
	...    ${tree_node_room_report},${SWITCH_NAME},05,${SC Duplex},No,5,6,7,8,9,10,11,12,13,14	 
    ...    ${tree_node_rack_report},${SWITCH_NAME_3},01,${RJ-45},No,11,12,13,14,15,16,17,18,19,20
	...    ${tree_node_rack_report},${SWITCH_NAME_3},02,${LC},No,12,13,14,15,16,17,18,19,20,21
	...    ${tree_node_rack_report},${SWITCH_NAME_3},03,${MPO12},No,13,14,15,16,17,18,19,20,21,22
	...    ${tree_node_rack_report},${SWITCH_NAME_3},04,${MPO24},No,14,15,16,17,18,19,20,21,22,23
	...    ${tree_node_rack_report},${SWITCH_NAME_3},05,${SC Duplex},No,15,16,17,18,19,20,21,22,23,24
	...    ${tree_node_room_report},${SWITCH_NAME},06,${RJ-45},No,,,,,,,,,,,	 
    ${rows_list}    Create List    1    2    3    4    5    7    8    9    10    11    6	

    :FOR    ${i}    IN RANGE    0    len(${rows_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

(SM-29576-08-09-10-11)_Verify user can generate Network Equipment Port Information report for MNE in Room/Rack   
    [Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Restore Database    ${RESTORE_FILE_NAME}    ${DIR_FILE_BK}
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Select Main Menu    ${Site Manager}
    ...    AND    Delete Object On Content Table     ${SITE_NODE}
    ...    AND    Close Browser
   
    [Tags]    Sanity
      
    # (SM-29576-08) Verify user can generate Network Equipment Port Information report for MNE in Room/Rack with adding the fields in Configuration section
    ${report_name}    Set Variable    SM-29576-08
    ${building_name}    Set Variable    Building_SM29576_08
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}
    ${tree_node_rack_report}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME} ${SLASH} ${ROOM_NAME} ${SLASH} 1:1 ${RACK_NAME}  
    
    # Create a "Network Equipment Port Information" report
    # . On Edit layout page, add following fields to the contain of report
    # Port Configuration
    # Service 01 to Service 12
    # . Add Building 01/Floor 01/Room 01/Rack 001
    # . In test harness file, setup port configuration for some ports on MNEs 01 & 02 as following
    # + MPO12 port 01, 02 with 1 channel as 1x100G, 1x40G (set service Data/Voice for all services fields).
    # + MPO12 port 03, 04 with 4 channels as 4x10G, 4x25G (set service Data/Voice for all services fields)
    # + MPO24 port 05,06, 07 with 1, 3 and 12 channels as 1x100G, 3x40G and 12x10G (set service Data/Voice for all services fields)
    # + RJ-45 port 08 with 1 channel e.g. 10M or Mgmt
    # + LC port 08 with 1 channel e.g 1G or 40 BD
    # . Add MNE 01 to Room 01 and MNE 02 to Rack 001
    # . Sync these MNEs
    # . Restore DB with already data    
    # 1. Go to Report tab
    # 2. Select "Network Equipment Port Information" pre-conditional report on Reports page
    # 3. Click on View button
    # 4. On Select filter page, select as
    # + Location: Select All
    # + Link Status: All
    # + Uplink: All
    # + Patching Status: All
    # 5. Click on View button on Edit filter page
    Select Main Menu    ${Reports}
    View Report    ${report_name}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
	Sort View Report Table By Column Name    Location    typeSort=desc
	Sort View Report Table By Column Name    Location    typeSort=asc
    # 6. Observe the result
    ${headers}    Set Variable    Location,Equipment,GBIC,Port Name,Port Type,Port Configuration,Service 01,Service 02,Service 03,Service 04,Service 05,Service 06,Service 07,Service 08,Service 09,Service 10,Service 11,Service 12
	${values_list}    Create List
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 01,01,${MPO24},1x100G,,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 02,01,${MPO24},3x40G,Voice,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 02,01,${MPO24},3x40G,,Voice,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 02,01,${MPO24},3x40G,,,Voice,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 03,01,${MPO24},12x10G,Data,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 03,01,${MPO24},12x10G,,Data,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 03,01,${MPO24},12x10G,,,Data,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 03,01,${MPO24},12x10G,,,,Data,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 03,01,${MPO24},12x10G,,,,,Data,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 03,01,${MPO24},12x10G,,,,,,Data,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 03,01,${MPO24},12x10G,,,,,,,Data,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 03,01,${MPO24},12x10G,,,,,,,,Data,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 03,01,${MPO24},12x10G,,,,,,,,,Data,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 03,01,${MPO24},12x10G,,,,,,,,,,Data,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 03,01,${MPO24},12x10G,,,,,,,,,,,Data, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 03,01,${MPO24},12x10G,,,,,,,,,,,,Data
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 05,01,${MPO12},1x100G,,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 06,01,${MPO12},1x40G,,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 07,01,${MPO12},4x10G,Data,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 07,01,${MPO12},4x10G,,Voice,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 07,01,${MPO12},4x10G,,,Data,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 07,01,${MPO12},4x10G,,,,Voice,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 08,01,${MPO12},4x25G,Voice,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 08,01,${MPO12},4x25G,,Data,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 08,01,${MPO12},4x25G,,,Voice,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME},GBIC Slot 08,01,${MPO12},4x25G,,,,Data,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME_2},,01,${RJ-45},1G,Voice,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME_2},,02,${LC},100G,Data,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME_2},,02,${LC},100G,Data,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME_2},,02,${LC},100G,Data,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME_2},,03 A,${LC},----,,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME_2},,03 B,${LC},----,,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME_2},,04,${LC},----,,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME_2},,05 A,${LC},----,,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME_2},,05 B,${LC},----,,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME_2},,06,${LC},----,,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME_2},,06 A,${LC},----,,,,,,,,,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME_2},,06 B,${LC},----,,,,,,,,,,,, 
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18    19    20    
    ...    21    22    23    24    25    26    27    28    29    30    31    32    33    34    35    36    37    38
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
    # (SM-29576-09) Verify user can generate Network Equipment Port Information report for MNE in Room/Rack with adding the fields in Status section

    ${report_name}    Set Variable    SM-29576-09
    ${building_name}    Set Variable    Building_SM29576_08
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}
    ${tree_node_rack_report}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME} ${SLASH} ${ROOM_NAME} ${SLASH} 1:1 ${RACK_NAME}    
    
    # Create a "Network Equipment Port Information" report
    # . On Edit layout page, add following fields to the contain of report
    # Port Configuration
    # Service 01 to Service 12
    # . Add Building 01/Floor 01/Room 01/Rack 001
    # . In test harness file, setup port configuration for some ports on MNEs 01 & 02 as following
    # + MPO12 port 01, 02 with 1 channel as 1x100G, 1x40G (set service Data/Voice for all services fields).
    # + MPO12 port 03, 04 with 4 channels as 4x10G, 4x25G (set service Data/Voice for all services fields)
    # + MPO24 port 05,06, 07 with 1, 3 and 12 channels as 1x100G, 3x40G and 12x10G (set service Data/Voice for all services fields)
    # + RJ-45 port 08 with 1 channel e.g. 10M or Mgmt
    # + LC port 08 with 1 channel e.g 1G or 40 BD
    # . Add MNE 01 to Room 01 and MNE 02 to Rack 001
    # . Sync these MNEs
    # . Restore DB with already data    
    # 1. Go to Report tab
    # 2. Select "Network Equipment Port Information" pre-conditional report on Reports page
    # 3. Click on View button
    # 4. On Select filter page, select as
    # + Location: Select All
    # + Link Status: All
    # + Uplink: All
    # + Patching Status: All
    # 5. Click on View button on Edit filter page
    Select Main Menu    ${Reports}
    View Report    ${report_name}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
	Sort View Report Table By Column Name    Location    typeSort=desc
	Sort View Report Table By Column Name    Location    typeSort=asc
    # 6. Observe the result
    ${headers}    Set Variable    Location,Equipment,GBIC,Port Name,Port Type,Port Connection,Patching Status,Critical,Not Available,Reserved,Service Designation,Route Designation,Uplink
	${values_list}    Create List
	...    ${tree_node_rack_report},Switch 01,GBIC Slot 01,01,MPO24,No,Available,Yes,0,0,,,No
	...    ${tree_node_rack_report},Switch 01,GBIC Slot 02,01,MPO24,No,Available,No,1,0,,,No
	...    ${tree_node_rack_report},Switch 01,GBIC Slot 02,01,MPO24,No,Available,No,1,0,,,No
	...    ${tree_node_rack_report},Switch 01,GBIC Slot 02,01,MPO24,No,Available,No,1,0,,,No
	...    ${tree_node_rack_report},Switch 01,GBIC Slot 03,01,MPO24,No,Available,No,0,1,,,No
	...    ${tree_node_rack_report},Switch 01,GBIC Slot 03,01,MPO24,No,Available,No,0,1,,,No
	...    ${tree_node_rack_report},Switch 01,GBIC Slot 05,01,MPO12,No,Available,No,0,0,,,No
	...    ${tree_node_rack_report},Switch 01,GBIC Slot 06,01,MPO12,No,Available,No,0,0,,,No
	...    ${tree_node_rack_report},Switch 01,GBIC Slot 07,01,MPO12,No,Available,No,0,0,,,No
	...    ${tree_node_rack_report},Switch 01,GBIC Slot 07,01,MPO12,No,Available,No,0,0,,,No
	...    ${tree_node_rack_report},Switch 01,GBIC Slot 08,01,MPO12,No,Available,No,0,0,,,No
	...    ${tree_node_rack_report},Switch 01,GBIC Slot 08,01,MPO12,No,Available,No,0,0,,,No
	...    ${tree_node_rack_report},Switch 02,,01,RJ-45,No,Available,No,0,0,,,No
	...    ${tree_node_rack_report},Switch 02,,02,LC,No,Available,No,0,0,Ser_01,,No
	...    ${tree_node_rack_report},Switch 02,,02,LC,No,Available,No,0,0,Ser_01,,No
	...    ${tree_node_rack_report},Switch 02,,02,LC,No,Available,No,0,0,Ser_01,,No
	...    ${tree_node_rack_report},Switch 02,,04,LC,No,In Use - Pending,No,0,0,,,No
	...    ${tree_node_rack_report},Switch 02,,06,LC,Yes (cabled),In Use,No,0,0,,,No
	...    ${tree_node_rack_report},Switch 02,,06 B,LC,Yes (cabled),Available,No,0,0,,Route_01,No
	...    ${tree_node_rack_report},Switch 02,,06 A,LC,Yes (cabled),Available,No,0,0,,Route_01,No
	...    ${tree_node_rack_report},Switch 02,,03 B,LC,Yes (patched),In Use,No,0,0,,,Yes
	...    ${tree_node_rack_report},Switch 02,,03 A,LC,Yes (patched),In Use,No,0,0,,,Yes
	...    ${tree_node_rack_report},Switch 02,,05 B,LC,Yes (patched),Available - Pending,No,0,0,,,No
	...    ${tree_node_rack_report},Switch 02,,05 A,LC,Yes (patched),Available - Pending,No,0,0,,,No
    ${rows_list}    Create List    1    2    3    4    5    16    17    18    19    20    23    24    27    28    29    30    33    36    38    37    32    31    35    34 
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
    # (SM-29576-10) Verify user can generate "Network Equipment Port Information" report for MNE in Room/Rack with adding the fields in Details section
       
    ${report_name}    Set Variable    SM-29576-10
    ${building_name}    Set Variable    Building_SM29576_10
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}
    ${tree_node_rack_report}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME} ${SLASH} ${ROOM_NAME} ${SLASH} 1:1 ${RACK_NAME}    
    
    # Create a "Network Equipment Port Information" report
    # . On Edit layout page, add following fields to the contain of report
    # Port Configuration
    # Service 01 to Service 12
    # . Add Building 01/Floor 01/Room 01/Rack 001
    # . In test harness file, setup port configuration for some ports on MNEs 01 & 02 as following
    # + MPO12 port 01, 02 with 1 channel as 1x100G, 1x40G (set service Data/Voice for all services fields).
    # + MPO12 port 03, 04 with 4 channels as 4x10G, 4x25G (set service Data/Voice for all services fields)
    # + MPO24 port 05,06, 07 with 1, 3 and 12 channels as 1x100G, 3x40G and 12x10G (set service Data/Voice for all services fields)
    # + RJ-45 port 08 with 1 channel e.g. 10M or Mgmt
    # + LC port 08 with 1 channel e.g 1G or 40 BD
    # . Add MNE 01 to Room 01 and MNE 02 to Rack 001
    # . Sync these MNEs
    # . Restore DB with already data    
    # 1. Go to Report tab
    # 2. Select "Network Equipment Port Information" pre-conditional report on Reports page
    # 3. Click on View button
    # 4. On Select filter page, select as
    # + Location: Select All
    # + Link Status: All
    # + Uplink: All
    # + Patching Status: All
    # 5. Click on View button on Edit filter page
    Select Main Menu    ${Reports}
    View Report    ${report_name}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
	Sort View Report Table By Column Name    Location    typeSort=desc
	Sort View Report Table By Column Name    Location    typeSort=asc
    # 6. Observe the result
    ${headers}    Set Variable    Location;Equipment;Card;Port Name;Port Type;Port Connection;Unique ID;VLAN;Voice VLAN;Description
	${values_list}    Create List
	...    ${tree_node_rack_report};Switch 01;Card 01;01;RJ-45;No;a03d6fc1d530;310;;
	...    ${tree_node_rack_report};Switch 01;Card 01;12;RJ-45;No;a03d6fc1d53b;313;413;
	...    ${tree_node_rack_report};Switch 01;Card 01;22;RJ-45;No;a03d6fc1d545;313;413;
	...    ${tree_node_rack_report};Switch 01;Card 01;36;RJ-45;No;a03d6fc1d553;313;413;
	...    ${tree_node_rack_report};Switch 01;Card 01;48;RJ-45;No;a03d6fc1d55f;Trunk (111,511);;
	...    ${tree_node_rack_report};Switch 01;Card 02;01;RJ-45;No;a0e0afb52b20;310;;
	...    ${tree_node_rack_report};Switch 01;Card 02;15;RJ-45;No;a0e0afb52b2e;313;413;
	...    ${tree_node_rack_report};Switch 01;Card 02;27;RJ-45;No;a0e0afb52b3a;313;413;
	...    ${tree_node_rack_report};Switch 01;Card 02;35;RJ-45;No;a0e0afb52b42;313;413;
	...    ${tree_node_rack_report};Switch 01;Card 02;48;RJ-45;No;a0e0afb52b4f;Trunk (111,511);;
	...    ${tree_node_rack_report};Switch 01;Card 03;01;RJ-45;No;a0e0afb52a60;310;;
	...    ${tree_node_rack_report};Switch 01;Card 03;25;RJ-45;No;a0e0afb52a78;313;413;
	...    ${tree_node_rack_report};Switch 01;Card 03;48;RJ-45;No;a0e0afb52a8f;Trunk (111,511);;
	...    ${tree_node_rack_report};Switch 01;Card 04;01;RJ-45;No;0081c4747980;310;;
	...    ${tree_node_rack_report};Switch 01;Card 04;24;RJ-45;No;0081c4747997;302;;
	...    ${tree_node_rack_report};Switch 01;Card 04;48;RJ-45;No;0081c47479af;Trunk (111,511);;
	...    ${tree_node_rack_report};Switch 01;Card 05;01;LC;No;843dc61ca380;Trunk;;
	...    ${tree_node_rack_report};Switch 01;Card 06;01;LC;No;843dc61ca388;Trunk;;
	...    ${tree_node_rack_report};Switch 01;Card 07;01;RJ-45;No;0081c4747f20;310;;
	...    ${tree_node_rack_report};Switch 01;Card 07;26;RJ-45;No;0081c4747f39;313;413;
	...    ${tree_node_rack_report};Switch 01;Card 07;48;RJ-45;No;0081c4747f4f;Trunk (111,511);;
    ${rows_list}    Create List    1    12    22    36    48    49    63    75    83    96    97    121    144    145    168    192    193    194    195    220    242
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]    delimiter=;
	
    # (SM-29576-11) Verify user can generate "Network Equipment Port Information" report for MNE in Room/Rack with adding the fields in Details section
       
    ${report_name}    Set Variable    SM-29576-11
    ${building_name}    Set Variable    Building_SM29576_11
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ${tree_node_room_report}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME} ${SLASH} ${ROOM_NAME}
    
    # Create a "Network Equipment Port Information" report
    # . On Edit layout page, add following fields to the contain of report
    # Port Configuration
    # Service 01 to Service 12
    # . Add Building 01/Floor 01/Room 01/Rack 001
    # . In test harness file, setup port configuration for some ports on MNEs 01 & 02 as following
    # + MPO12 port 01, 02 with 1 channel as 1x100G, 1x40G (set service Data/Voice for all services fields).
    # + MPO12 port 03, 04 with 4 channels as 4x10G, 4x25G (set service Data/Voice for all services fields)
    # + MPO24 port 05,06, 07 with 1, 3 and 12 channels as 1x100G, 3x40G and 12x10G (set service Data/Voice for all services fields)
    # + RJ-45 port 08 with 1 channel e.g. 10M or Mgmt
    # + LC port 08 with 1 channel e.g 1G or 40 BD
    # . Add MNE 01 to Room 01 and MNE 02 to Rack 001
    # . Sync these MNEs
    # . Restore DB with already data
    # Restore Database    ${RESTORE_FILE_NAME}    ${DIR_FILE_BK}
    # Login To SM    ${USERNAME}    ${PASSWORD}
    # 1. Go to Report tab
    # 2. Select "Network Equipment Port Information" pre-conditional report on Reports page
    # 3. Click on View button
    # 4. On Select filter page, select as
    # + Location: Select All
    # + Link Status: All
    # + Uplink: All
    # + Patching Status: All
    # 5. Click on View button on Edit filter page
    Select Main Menu    ${Reports}
    View Report    ${report_name}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
	Sort View Report Table By Column Name    Location    typeSort=desc
	Sort View Report Table By Column Name    Location    typeSort=asc
    # 6. Observe the result
    ${headers}    Set Variable    Location;Equipment;Port Name;Port Type;Port Connection;PoE Type;PoE Port Status;PoE Allocated (W);PoE Consumption (W)
	${values_list}    Create List
	...    ${tree_node_room_report};Stack-1;01;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1;02;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1;09;RJ-45;No;30 (W), Type 2;PoE in Use;15.4;15.4
	...    ${tree_node_room_report};Stack-1;10;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1;11;RJ-45;No;30 (W), Type 2;PoE in Use;15.4;15.4
	...    ${tree_node_room_report};Stack-1;12;RJ-45;No;30 (W), Type 2;PoE in Use;15.4;15.4
	...    ${tree_node_room_report};Stack-1;22;RJ-45;No;30 (W), Type 2;PoE in Use;15.4;15.4
	...    ${tree_node_room_report};Stack-1;24;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1;25;RJ-45;No;30 (W), Type 2;PoE in Use;15.4;15.4
	...    ${tree_node_room_report};Stack-1;30;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1;36;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1;48;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1;01;LC;No;;;;
	...    ${tree_node_room_report};Stack-1;01;LC;No;;;;
	...    ${tree_node_room_report};Stack-1 (2);01;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1 (2);11;RJ-45;No;30 (W), Type 2;PoE in Use;15.4;15.4
	...    ${tree_node_room_report};Stack-1 (2);22;RJ-45;No;30 (W), Type 2;PoE in Use;15.4;15.4
	...    ${tree_node_room_report};Stack-1 (2);30;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1 (2);48;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1 (2);01;LC;No;;;;
	...    ${tree_node_room_report};Stack-1 (2);01;LC;No;;;;
	...    ${tree_node_room_report};Stack-1 (3);01;RJ-45;No;30 (W), Type 2;PoE in Use;4.0;4.0
	...    ${tree_node_room_report};Stack-1 (3);15;RJ-45;No;30 (W), Type 2;PoE in Use;30.0;30.0
	...    ${tree_node_room_report};Stack-1 (3);24;RJ-45;No;30 (W), Type 2;PoE in Use;4.0;4.0
	...    ${tree_node_room_report};Stack-1 (3);25;RJ-45;No;30 (W), Type 2;PoE in Use;4.0;4.0
	...    ${tree_node_room_report};Stack-1 (3);48;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1 (3);01;LC;No;;;;
	...    ${tree_node_room_report};Stack-1 (3);01;LC;No;;;;
	...    ${tree_node_room_report};Stack-1 (4);01;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1 (4);12;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1 (4);33;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1 (4);48;RJ-45;No;30 (W), Type 2;PoE Not in Use;0.0;0.0
	...    ${tree_node_room_report};Stack-1 (4);01;LC;No;;;;
	...    ${tree_node_room_report};Stack-1 (4);01;LC;No;;;;
    ${rows_list}    Create List    1    2    9    10    11    12    22    24    25    30    36    48    49    50    
    ...    51    61    72    80    98    99    100
    ...    101    115    124    125    148    149    150
    ...    151    162    183    198    199    200
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]    delimiter=;

(Bulk_SM-29576-13-14)_Verify User Can Generate Network Equipment Port Information Report For MNE In Room/Rack with adding the fields in Connected Equipment/Devices Section
    [Setup]    Run Keywords    Set Test Variable    ${port_field_label_1}    Test 1    
    ...    AND    Set Test Variable    ${port_field_label_2}    Test 2    
    ...    AND    Set Test Variable    ${port_field_label_3}    Test 3
    ...    AND    Set Test Variable    ${port_field_label_4}    Test 4
    ...    AND    Set Test Variable    ${port_field_label_5}    Test 5    
    ...    AND    Set Test Variable    ${building_name}    SM-29576-14
    ...    AND    Set Test Variable    ${ip_address}    10.5.1.108
    ...    AND    Set Test Variable    ${report_name}   SM-29576-14   
    ...    AND    Set Test Variable    ${file_bk}    SM9.1_TC_SM-29576-13-14.bak
    ...    AND    Open SM Login Page   
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}       
 
    [Teardown]    Run Keywords    Select Main Menu    ${Reports}   
    ...    AND    Delete Report    ${report_name}
    ...    AND    Select Main Menu    ${Site Manager}
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Close Browser
       
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}
    ${tree_node_switch_1}    Set Variable    ${tree_node_room}/${SWITCH_NAME}
    ${tree_node_switch_3}    Set Variable    ${tree_node_rack}/${SWITCH_NAME_3}   
    ${tree_node_room_report}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_report}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME} ${SLASH} ${ROOM_NAME} ${SLASH} 1:1 ${RACK_NAME}
    
    ### SM-29576-14_Verify "Network Equipment Port Information" report is available in Report after upgrading from previous released version
    # 1. Restore Data from SM9.1 on the latest build
    Restore Database    ${_file_bk}    ${DIR_FILE_BK}
    Login To SM    ${USERNAME}    ${PASSWORD}
    
    # 2. Go to Report tab
	# 3. Click on Add button
	# 4. Select All
	# 5. Observe the result
	Select Main Menu    ${Reports}
    Select Category Report To Add    All
    Check Report Category Exist    All Report    ${REPORT_TYPE}    ${REPORT_DESCRIPTION}
    
	# 6. Back to Report page
	# 7. Click on Add then select Properties
	# 8. Observe the result
    Select Main Menu    ${Reports}
    Select Category Report To Add    Properties
    Check Report Category Exist    Properties Report    ${REPORT_TYPE}    ${REPORT_DESCRIPTION}	
    
    ### SM-29576-13_Verify user can generate  "Network Equipment Port Information" report for MNE in Room/Rack with adding the fields in Connected Equipment/Devices section    
    # . Create a "Network Equipment Port Information" report
	# . On Edit layout page, add more fields to the contain of report as below:
	# Connected Equipment Name
	# Connected Equipment Type
	# Device Type
	# Connected Equipment MAC Address
	# Connected Equipment IP Address
	# Connected Equipment Location
	Select Main Menu    ${Reports}
    Delete Report    ${report_name}
    Add Report        All    Network Equipment Port Information    ${report_name}    editLayout=${True}    sourcePane=ContentLeft    destinationPane=Content
    ...    items=Connected Equipment/Devices->Connected Equipment Location,Connected Equipment/Devices->Connected Equipment IP Address,Connected Equipment/Devices->Connected Equipment MAC Address,Connected Equipment/Devices->Device Type,Connected Equipment/Devices->Connected Equipment Type,Connected Equipment/Devices->Connected Equipment Name
    ...    destinationItem=Link Status

	# . Add Building 01/ Floor 01/ Room 01/ 1:1 Rack 001
	# . Setup MNE 01 & 02 having some DDes
	# . Add MNE 01 to Room and MNE02 to Rack 001
	# . Sync and discover device these MNEs
	# . Add MNE 03, 04 to Room 01 and Rack 001
	# . Add Faceplate 01 to Room 01 
	# . Add Quareo the same port type with MNE 02 /01 into Rack 001
	# . Do patching from MNE 03/01 to Faceplate 01/01
	# . Add NE 01 to Rack 001 with same port types of MNE 04
	# . Do patching from MNE 02/01 and Quareo 01/01
	# 1. Go to Report tab
	# 2. Select "Network Equipment Port Information" pre-conditional report on Reports page
	# 3. Click on View button
	# 4. On Select filter page, select as
	# + Location: All
	# + Link Status: All
	# + Uplink: All
	# + Patching Status: All
	# 5. Click on View button on Edit filter page
	# 6. Observe the result
	Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
	Sort View Report Table By Column Name    Location    typeSort=desc
	Sort View Report Table By Column Name    Location    typeSort=asc
	${headers}    Set Variable    Location,Equipment,Port Name,Port Type,Port Connection,Connected Equipment Name,Connected Equipment Type,Device Type,Connected Equipment MAC Address,Connected Equipment IP Address,Connected Equipment Location
	${values_list}    Create List
	...    ${tree_node_room_report},${SWITCH_NAME_4},01,${RJ-45},Yes (patched),,Faceplate Outlet,,,, 
	...    ${tree_node_room_report},${SWITCH_NAME_4},15,${RJ-45},Yes (patched),Device 01,Devices,Networked Device,00145EE04EB1,10.26.8.1,${tree_node_room_report}
	...    ${tree_node_room_report},${SWITCH_NAME},01,${RJ-45},Yes (patched),Device 02,Devices,Computer,11:11:11:11:11:11,1.2.3.4,${tree_node_room_report}
	...    ${tree_node_room_report},${SWITCH_NAME},03,${RJ-45},Yes (patched),Device 04,Devices,Phone,11:01:01:01:01:01,,${tree_node_room_report}
	...    ${tree_node_room_report},${SWITCH_NAME},02 B,${LC},Yes (patched),Device 03,Devices,Fax,,2.2.2.2,${tree_node_room_report}
	...    ${tree_node_room_report},${SWITCH_NAME},02 A,${LC},Yes (patched),Device 03,Devices,Fax,,2.2.2.2,${tree_node_room_report}
	...    ${tree_node_room_report},${SWITCH_NAME},05 B,${SC_DUPLEX},Yes (patched),Device 06,Devices,Access Point,,,${tree_node_room_report}
	...    ${tree_node_room_report},${SWITCH_NAME},05 A,${SC_DUPLEX},Yes (patched),Device 06,Devices,Access Point,,,${tree_node_room_report}
	...    ${tree_node_room_report},${SWITCH_NAME},04 B,${LC},Yes (patched),Device 05,Devices,Printer,,,${tree_node_room_report}
	...    ${tree_node_room_report},${SWITCH_NAME},04 A,${LC},Yes (patched),Device 05,Devices,Printer,,,${tree_node_room_report}
	...    ${tree_node_room_report},${SWITCH_NAME},06 B,${LC},Yes (patched),,Faceplate Outlet,,,, 
	...    ${tree_node_room_report},${SWITCH_NAME},06 A,${LC},Yes (patched),,Faceplate Outlet,,,, 
	...    ${tree_node_rack_report},${SWITCH_NAME_3},01 B,${LC},Yes (patched),Server 01,Networked Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},01 A,${LC},Yes (patched),Server 01,Networked Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},02 B,${LC},Yes (patched),Server 02,Networked Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},02 A,${LC},Yes (patched),Server 02,Networked Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},03 B,${LC},Yes (patched),Server 03,Networked Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},03 A,${LC},Yes (patched),Server 03,Networked Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},04,${LC},Yes (patched),${SWITCH_NAME_3},Network Equipment,,,10.5.1.108,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},04 B,${LC},Yes (patched),${SWITCH_NAME_3},Network Equipment,,,10.5.1.108,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},04 B,${LC},Yes (patched),Server 04,Networked Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},04 A,${LC},Yes (patched),${SWITCH_NAME_3},Network Equipment,,,10.5.1.108,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},04 A,${LC},Yes (patched),Server 04,Networked Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},05,${LC},Yes (patched),${SWITCH_NAME_3},Network Equipment,,,10.5.1.108,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},05 B,${LC},Yes (patched),${SWITCH_NAME_3},Network Equipment,,,10.5.1.108,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},05 A,${LC},Yes (patched),${SWITCH_NAME_3},Network Equipment,,,10.5.1.108,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},05 A,${LC},Yes (patched),Server 05,Networked Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},06,${LC},Yes (patched),MXOCCSWT03_A,Network Equipment,,,10.5.3.224,${tree_node_room_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},06 B,${LC},Yes (patched),Server 07,Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},06 A,${LC},Yes (patched),Server 07,Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},07 B,${LC},Yes (patched),Switch 01/GBIC Slot 01,Managed Network Equipment,,,,${tree_node_room_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},07 B,${LC},Yes (patched),Switch 02,Managed Network Equipment,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},07 A,${LC},Yes (patched),Switch 01/GBIC Slot 01,Managed Network Equipment,,,,${tree_node_room_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},07 A,${LC},Yes (patched),Switch 02,Managed Network Equipment,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},10 B,${LC},Yes (patched),Server 06,Networked Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_3},10 A,${LC},Yes (patched),Server 06,Networked Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_2},01,${RJ-45},Yes (patched),,Quareo Port,,,,
	...    ${tree_node_rack_report},${SWITCH_NAME_2},02 B,${LC},Yes (patched),${SWITCH_NAME_3},Network Equipment,,,10.5.1.108,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_2},02 A,${LC},Yes (patched),${SWITCH_NAME_3},Network Equipment,,,10.5.1.108,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_2},05 B,${SC_DUPLEX},Yes (patched),Server 07,Device in Rack,,,,${tree_node_rack_report}
	...    ${tree_node_rack_report},${SWITCH_NAME_2},05 A,${SC_DUPLEX},Yes (patched),Server 07,Device in Rack,,,,${tree_node_rack_report}	
		 
    ${rows_list}    Create List    1    15    21    24    23    22    28    27    26    25    30    29
    ...    32    31    34    33    36    35    37    40    41    38    39    42    45    43    44    46
    ...    48    47    51    52    49    50    56    55    60    62    61    66    65	

    :FOR    ${i}    IN RANGE    0    len(${rows_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
