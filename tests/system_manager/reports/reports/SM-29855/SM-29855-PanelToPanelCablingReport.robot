*** Settings ***
Library   ../../../../../py_sources/logigear/setup.py        
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/reports/reports/ReportsPage${PLATFORM}.py    	
Library   ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py    

Resource    ../../../../../resources/constants.robot

Suite Setup    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Restore Database    ${RESTORE_FILE_NAME}    ${DIR_FILE_BK}
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}

Suite Teardown    Close Browser

Default Tags    Reports
Force Tags    SM-29855

*** Variables ***
${BUILDING_NAME}    SM-29855
${FLOOR_NAME}    Panel to Panel Cabling
${RACK_NAME}    Rack 001
${RESTORE_FILE_NAME}    DB SM-29855.bak
${REPORT_NAME}    Panel-to-Panel Cabling

*** Test Cases ***
(SM-29855-22) Verify that Panel to Equipment Reports shows data correctly for new 6xLC EB in circuit:_LC Panel 01/01-06 -cabled 6xLC EB to-> MPO12 Panel 02/01 -patched to-> MPO12 Panel 03/01-cabled 4xLC to-> LC Panel 04/01-04.
    
    [Tags]    Sanity
    
    ${room_name}    Set Variable    TC_22
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${room_name}
    ${tree_node_location_report}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name} / 1:1 ${RACK_NAME}
    
    # 1. Add:
    # _Building 01/Floor 01/Room 01/1:1 Rack 001
    # + Add to Rack:
    # _ LC Panel 01,  MPO12 Panel 02, MPO12 Panel 03, LC Panel 04
    # 2. Create Circuit as below:
    # _ LC Panel 01/01-06 -cabled 6xLC EB to-> MPO12 Panel 02/01 -patched to-> MPO12 Panel 03/01-cabled 4xLC to-> LC Panel 04/01-04
    # 3. Go to Reports, Create "Cabling->Panel to Equipment Cabling" report with data as below:
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
    # 4. Check Result on View Report page with Location is current Building 
    ${headers}    Set Variable    Location (Panel1),Panel (1),Module (1),Port (1),Cabled to Port,Location (Panel2),Panel (2),Module (2),Port (2)
	${values_list}    Create List
	...    ${tree_node_location_report},Panel 01,,01,1:1 Rack 001 / Panel 2 / MPO 1 / Pair 1,${tree_node_location_report},Panel 02,,01 / Pair 1
	...    ${tree_node_location_report},Panel 01,,02,1:1 Rack 001 / Panel 2 / MPO 1 / Pair 2,${tree_node_location_report},Panel 02,,01 / Pair 2
	...    ${tree_node_location_report},Panel 01,,03,1:1 Rack 001 / Panel 2 / MPO 1 / Pair 3,${tree_node_location_report},Panel 02,,01 / Pair 3
	...    ${tree_node_location_report},Panel 01,,04,1:1 Rack 001 / Panel 2 / MPO 1 / Pair 4,${tree_node_location_report},Panel 02,,01 / Pair 4
	...    ${tree_node_location_report},Panel 01,,05,1:1 Rack 001 / Panel 2 / MPO 1 / Pair 5,${tree_node_location_report},Panel 02,,01 / Pair 5
	...    ${tree_node_location_report},Panel 01,,06,1:1 Rack 001 / Panel 2 / MPO 1 / Pair 6,${tree_node_location_report},Panel 02,,01 / Pair 6
	...    ${tree_node_location_report},Panel 02,,01 / Pair 1,1:1 Rack 001 / Panel 1 / 01,${tree_node_location_report},Panel 01,,01
	...    ${tree_node_location_report},Panel 02,,01 / Pair 2,1:1 Rack 001 / Panel 1 / 02,${tree_node_location_report},Panel 01,,02
	...    ${tree_node_location_report},Panel 02,,01 / Pair 3,1:1 Rack 001 / Panel 1 / 03,${tree_node_location_report},Panel 01,,03
	...    ${tree_node_location_report},Panel 02,,01 / Pair 4,1:1 Rack 001 / Panel 1 / 04,${tree_node_location_report},Panel 01,,04
	...    ${tree_node_location_report},Panel 02,,01 / Pair 5,1:1 Rack 001 / Panel 1 / 05,${tree_node_location_report},Panel 01,,05
	...    ${tree_node_location_report},Panel 02,,01 / Pair 6,1:1 Rack 001 / Panel 1 / 06,${tree_node_location_report},Panel 01,,06
    ...    ${tree_node_location_report},Panel 03,,01 / 1-1,1:1 Rack 001 / Panel 4 / 01,${tree_node_location_report},Panel 04,,01
	...    ${tree_node_location_report},Panel 03,,01 / 2-2,1:1 Rack 001 / Panel 4 / 02,${tree_node_location_report},Panel 04,,02
	...    ${tree_node_location_report},Panel 03,,01 / 3-3,1:1 Rack 001 / Panel 4 / 03,${tree_node_location_report},Panel 04,,03
	...    ${tree_node_location_report},Panel 03,,01 / 4-4,1:1 Rack 001 / Panel 4 / 04,${tree_node_location_report},Panel 04,,04
	...    ${tree_node_location_report},Panel 04,,01,1:1 Rack 001 / Panel 3 / MPO 1 / 1-1,${tree_node_location_report},Panel 03,,01 / 1-1
	...    ${tree_node_location_report},Panel 04,,02,1:1 Rack 001 / Panel 3 / MPO 1 / 2-2,${tree_node_location_report},Panel 03,,01 / 2-2
	...    ${tree_node_location_report},Panel 04,,03,1:1 Rack 001 / Panel 3 / MPO 1 / 3-3,${tree_node_location_report},Panel 03,,01 / 3-3
	...    ${tree_node_location_report},Panel 04,,04,1:1 Rack 001 / Panel 3 / MPO 1 / 4-4,${tree_node_location_report},Panel 03,,01 / 4-4
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18    19    20
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

(SM-29855-23) Verify that Panel to Equipment Reports shows data correctly for new 6xLC EB in circuit:LC Panel 01/01-06 -cabled 6xLC EB to-> DM12 Panel 02/01-06 -patched to-> LC Panel 03/01-0 -cabled 6xLC EB to-> DM12 Panel 04/01-06 -patchig to-> LC Panel 05/01-06  
    
    ${room_name}    Set Variable    TC_23
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${room_name}
    ${tree_node_location_report}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name} / 1:1 ${RACK_NAME}
       
    # 1. Add:
    # _Building 01/Floor 01/Room 01/1:1 Rack 001
    # + Add to Rack:
    # LC Panel 01, DM12 Panel 02, LC Panel 03, DM12 Panel 04, LC Panel 05
    # 2. Create Circuit as below:
    # _ LC Panel 01/01-06 -cabled 6xLC EB to-> DM12 Panel 02/01-06 -patched to-> LC Panel 03/01-06  -cabled 6xLC EB to-> DM12 Panel 04/01-06 -patchig to-> LC Panel 05/01-06
    
    # 3. Go to Reports, Create "Cabling->Panel to Equipment Cabling" report with data as below:
    # 4. Check Result on View Report page with Location is current Building 
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
    # 4. Check Result on View Report page with Location is current Building 
    ${headers}    Set Variable    Location (Panel1),Panel (1),Module (1),Port (1),Cabled to Port,Location (Panel2),Panel (2),Module (2),Port (2)
	${values_list}    Create List
	...    ${tree_node_location_report},Panel 01,,01,1:1 Rack 001 / Panel 2 / Module 1 / 01,${tree_node_location_report},Panel 02,Module 1A (DM12),01
	...    ${tree_node_location_report},Panel 01,,02,1:1 Rack 001 / Panel 2 / Module 1 / 02,${tree_node_location_report},Panel 02,Module 1A (DM12),02
	...    ${tree_node_location_report},Panel 01,,03,1:1 Rack 001 / Panel 2 / Module 1 / 03,${tree_node_location_report},Panel 02,Module 1A (DM12),03
	...    ${tree_node_location_report},Panel 01,,04,1:1 Rack 001 / Panel 2 / Module 1 / 04,${tree_node_location_report},Panel 02,Module 1A (DM12),04
	...    ${tree_node_location_report},Panel 01,,05,1:1 Rack 001 / Panel 2 / Module 1 / 05,${tree_node_location_report},Panel 02,Module 1A (DM12),05
	...    ${tree_node_location_report},Panel 01,,06,1:1 Rack 001 / Panel 2 / Module 1 / 06,${tree_node_location_report},Panel 02,Module 1A (DM12),06
    ...    ${tree_node_location_report},Panel 02,Module 1A (DM12),01,1:1 Rack 001 / Panel 1 / 01,${tree_node_location_report},Panel 01,,01
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),02,1:1 Rack 001 / Panel 1 / 02,${tree_node_location_report},Panel 01,,02
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),03,1:1 Rack 001 / Panel 1 / 03,${tree_node_location_report},Panel 01,,03
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),04,1:1 Rack 001 / Panel 1 / 04,${tree_node_location_report},Panel 01,,04
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),05,1:1 Rack 001 / Panel 1 / 05,${tree_node_location_report},Panel 01,,05
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),06,1:1 Rack 001 / Panel 1 / 06,${tree_node_location_report},Panel 01,,06
    ...    ${tree_node_location_report},Panel 03,,01,1:1 Rack 001 / Panel 5 / Module 1 / 01,${tree_node_location_report},Panel 04,Module 1A (DM12),01
	...    ${tree_node_location_report},Panel 03,,02,1:1 Rack 001 / Panel 5 / Module 1 / 02,${tree_node_location_report},Panel 04,Module 1A (DM12),02
	...    ${tree_node_location_report},Panel 03,,03,1:1 Rack 001 / Panel 5 / Module 1 / 03,${tree_node_location_report},Panel 04,Module 1A (DM12),03
	...    ${tree_node_location_report},Panel 03,,04,1:1 Rack 001 / Panel 5 / Module 1 / 04,${tree_node_location_report},Panel 04,Module 1A (DM12),04
	...    ${tree_node_location_report},Panel 03,,05,1:1 Rack 001 / Panel 5 / Module 1 / 05,${tree_node_location_report},Panel 04,Module 1A (DM12),05
	...    ${tree_node_location_report},Panel 03,,06,1:1 Rack 001 / Panel 5 / Module 1 / 06,${tree_node_location_report},Panel 04,Module 1A (DM12),06
    ...    ${tree_node_location_report},Panel 04,Module 1A (DM12),01,1:1 Rack 001 / Panel 4 / 01,${tree_node_location_report},Panel 03,,01
	...    ${tree_node_location_report},Panel 04,Module 1A (DM12),02,1:1 Rack 001 / Panel 4 / 02,${tree_node_location_report},Panel 03,,02
	...    ${tree_node_location_report},Panel 04,Module 1A (DM12),03,1:1 Rack 001 / Panel 4 / 03,${tree_node_location_report},Panel 03,,03
	...    ${tree_node_location_report},Panel 04,Module 1A (DM12),04,1:1 Rack 001 / Panel 4 / 04,${tree_node_location_report},Panel 03,,04
	...    ${tree_node_location_report},Panel 04,Module 1A (DM12),05,1:1 Rack 001 / Panel 4 / 05,${tree_node_location_report},Panel 03,,05
	...    ${tree_node_location_report},Panel 04,Module 1A (DM12),06,1:1 Rack 001 / Panel 4 / 06,${tree_node_location_report},Panel 03,,06
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

(SM-29855-24) Verify that Panel to Equipment Reports shows data correctly for new 6xLC EB in circuit:LC Panel 01/01-06 <-cabled 6xLC EB to- DM08 Panel 02/01-06(MPO 01) ->LC Panel 03/01-06  
    
    ${room_name}    Set Variable    TC_24
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${room_name}
    ${tree_node_location_report}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name} / 1:1 ${RACK_NAME}           
   
    # 1. Add:
    # _Building 01/Floor 01/Room 01/1:1 Rack 001
    # + Add to Rack:
    # LC Panel 01, DM12 Panel 02, LC Panel 03, DM12 Panel 04, LC Panel 05
    # 2. Create Circuit as below:
    # _ LC Panel 01/01-06 -cabled 6xLC EB to-> DM12 Panel 02/01-06 -patched to-> LC Panel 03/01-06  -cabled 6xLC EB to-> DM12 Panel 04/01-06 -patchig to-> LC Panel 05/01-06
    # 3. Go to Reports, Create "Cabling->Panel to Equipment Cabling" report with data as below:
    # 4. Check Result on View Report page with Location is current Building 
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
    # 4. Check Result on View Report page with Location is current Building 
    ${headers}    Set Variable    Location (Panel1),Panel (1),Module (1),Port (1),Cabled to Port,Location (Panel2),Panel (2),Module (2),Port (2)
	${values_list}    Create List
	...    ${tree_node_location_report},Panel 01,,01,1:1 Rack 001 / Panel 2 / Module 1 / MPO1-01,${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-01
	...    ${tree_node_location_report},Panel 01,,02,1:1 Rack 001 / Panel 2 / Module 1 / MPO1-02,${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-02
	...    ${tree_node_location_report},Panel 01,,03,1:1 Rack 001 / Panel 2 / Module 1 / MPO1-03,${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-03
	...    ${tree_node_location_report},Panel 01,,04,1:1 Rack 001 / Panel 2 / Module 1 / MPO1-04,${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-04
	...    ${tree_node_location_report},Panel 01,,05,1:1 Rack 001 / Panel 2 / Module 1 / MPO 1 ${LEFTBRACE}Pair 5${RIGHTBRACE},${tree_node_location_report},Panel 02,Module 1A (DM08),MPO 01 / Pair 5
	...    ${tree_node_location_report},Panel 01,,06,1:1 Rack 001 / Panel 2 / Module 1 / MPO 1 ${LEFTBRACE}Pair 6${RIGHTBRACE},${tree_node_location_report},Panel 02,Module 1A (DM08),MPO 01 / Pair 6
    ...    ${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-01,1:1 Rack 001 / Panel 1 / 01,${tree_node_location_report},Panel 01,,01
	...    ${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-03,1:1 Rack 001 / Panel 3 / 03,${tree_node_location_report},Panel 03,,03
	...    ${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-02,1:1 Rack 001 / Panel 1 / 02,${tree_node_location_report},Panel 01,,02
	...    ${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-04,1:1 Rack 001 / Panel 3 / 04,${tree_node_location_report},Panel 03,,04
	...    ${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-03,1:1 Rack 001 / Panel 1 / 03,${tree_node_location_report},Panel 01,,03
	...    ${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-04,1:1 Rack 001 / Panel 1 / 04,${tree_node_location_report},Panel 01,,04
	...    ${tree_node_location_report},Panel 02,Module 1A (DM08),MPO 01 / Pair 5,1:1 Rack 001 / Panel 1 / 05,${tree_node_location_report},Panel 01,,05
	...    ${tree_node_location_report},Panel 02,Module 1A (DM08),MPO 01 / Pair 6,1:1 Rack 001 / Panel 1 / 06,${tree_node_location_report},Panel 01,,06
    ...    ${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-01,1:1 Rack 001 / Panel 3 / 01,${tree_node_location_report},Panel 03,,01
	...    ${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-02,1:1 Rack 001 / Panel 3 / 02,${tree_node_location_report},Panel 03,,02
    ...    ${tree_node_location_report},Panel 03,,01,1:1 Rack 001 / Panel 2 / Module 1 / MPO1-01,${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-01
	...    ${tree_node_location_report},Panel 03,,02,1:1 Rack 001 / Panel 2 / Module 1 / MPO1-02,${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-02
	...    ${tree_node_location_report},Panel 03,,03,1:1 Rack 001 / Panel 2 / Module 1 / MPO1-03,${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-03
	...    ${tree_node_location_report},Panel 03,,04,1:1 Rack 001 / Panel 2 / Module 1 / MPO1-04,${tree_node_location_report},Panel 02,Module 1A (DM08),MPO1-04
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18    19    20
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	    
(SM-29855-25) Verify that Panel to Equipment Reports shows data correctly for new 6xLC EB in circuit:LC Panel 01/01-06 <-Cabled 6xLC EB to- DM12 Panel 02/01-06 -patched to-> DM12 Panel 03/01-06 -Cabled 6xLC EB-> LC Panel 04/01-06  
    
    ${room_name}    Set Variable    TC_25
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${room_name}
    ${tree_node_location_report}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name} / 1:1 ${RACK_NAME}
       
    # 1. Add:
    # _Building 01/Floor 01/Room 01/1:1 Rack 001
    # + Add to Rack:
    # LC Panel 01, DM12 Panel 02, LC Panel 03, DM12 Panel 04, LC Panel 05
    # 2. Create Circuit as below:
    # _ LC Panel 01/01-06 <-Cabled 6xLC EB to- DM12 Panel 02/01-06 -patched to-> DM12 Panel 03/01-06 -Cabled 6xLC EB-> LC Panel 04/01-06
    # 3. Go to Reports, Create "Cabling->Panel to Equipment Cabling" report with data as below:
    # 4. Check Result on View Report page with Location is current Building 
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
    # 4. Check Result on View Report page with Location is current Building 
    ${headers}    Set Variable    Location (Panel1),Panel (1),Module (1),Port (1),Cabled to Port,Location (Panel2),Panel (2),Module (2),Port (2)
	${values_list}    Create List
	...    ${tree_node_location_report},Panel 01,,01,1:1 Rack 001 / Panel 2 / Module 1 / 01,${tree_node_location_report},Panel 02,Module 1A (DM12),01
	...    ${tree_node_location_report},Panel 01,,02,1:1 Rack 001 / Panel 2 / Module 1 / 02,${tree_node_location_report},Panel 02,Module 1A (DM12),02
	...    ${tree_node_location_report},Panel 01,,03,1:1 Rack 001 / Panel 2 / Module 1 / 03,${tree_node_location_report},Panel 02,Module 1A (DM12),03
	...    ${tree_node_location_report},Panel 01,,04,1:1 Rack 001 / Panel 2 / Module 1 / 04,${tree_node_location_report},Panel 02,Module 1A (DM12),04
	...    ${tree_node_location_report},Panel 01,,05,1:1 Rack 001 / Panel 2 / Module 1 / 05,${tree_node_location_report},Panel 02,Module 1A (DM12),05
	...    ${tree_node_location_report},Panel 01,,06,1:1 Rack 001 / Panel 2 / Module 1 / 06,${tree_node_location_report},Panel 02,Module 1A (DM12),06
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),01,1:1 Rack 001 / Panel 1 / 01,${tree_node_location_report},Panel 01,,01
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),02,1:1 Rack 001 / Panel 1 / 02,${tree_node_location_report},Panel 01,,02
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),03,1:1 Rack 001 / Panel 1 / 03,${tree_node_location_report},Panel 01,,03
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),04,1:1 Rack 001 / Panel 1 / 04,${tree_node_location_report},Panel 01,,04
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),05,1:1 Rack 001 / Panel 1 / 05,${tree_node_location_report},Panel 01,,05
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),06,1:1 Rack 001 / Panel 1 / 06,${tree_node_location_report},Panel 01,,06
	...    ${tree_node_location_report},Panel 03,Module 1A (DM12),01,1:1 Rack 001 / Panel 4 / 01,${tree_node_location_report},Panel 04,,01
	...    ${tree_node_location_report},Panel 03,Module 1A (DM12),02,1:1 Rack 001 / Panel 4 / 02,${tree_node_location_report},Panel 04,,02
	...    ${tree_node_location_report},Panel 03,Module 1A (DM12),03,1:1 Rack 001 / Panel 4 / 03,${tree_node_location_report},Panel 04,,03
	...    ${tree_node_location_report},Panel 03,Module 1A (DM12),04,1:1 Rack 001 / Panel 4 / 04,${tree_node_location_report},Panel 04,,04
	...    ${tree_node_location_report},Panel 03,Module 1A (DM12),05,1:1 Rack 001 / Panel 4 / 05,${tree_node_location_report},Panel 04,,05
	...    ${tree_node_location_report},Panel 03,Module 1A (DM12),06,1:1 Rack 001 / Panel 4 / 06,${tree_node_location_report},Panel 04,,06
	...    ${tree_node_location_report},Panel 04,,01,1:1 Rack 001 / Panel 3 / Module 1 / 01,${tree_node_location_report},Panel 03,Module 1A (DM12),01
	...    ${tree_node_location_report},Panel 04,,02,1:1 Rack 001 / Panel 3 / Module 1 / 02,${tree_node_location_report},Panel 03,Module 1A (DM12),02
	...    ${tree_node_location_report},Panel 04,,03,1:1 Rack 001 / Panel 3 / Module 1 / 03,${tree_node_location_report},Panel 03,Module 1A (DM12),03
	...    ${tree_node_location_report},Panel 04,,04,1:1 Rack 001 / Panel 3 / Module 1 / 04,${tree_node_location_report},Panel 03,Module 1A (DM12),04
	...    ${tree_node_location_report},Panel 04,,05,1:1 Rack 001 / Panel 3 / Module 1 / 05,${tree_node_location_report},Panel 03,Module 1A (DM12),05
	...    ${tree_node_location_report},Panel 04,,06,1:1 Rack 001 / Panel 3 / Module 1 / 06,${tree_node_location_report},Panel 03,Module 1A (DM12),06
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
(SM-29855-26) Verify that Panel to Equipment Reports shows data correctly for new 6xLC EB in circuit:LC Panel 01/01-06 -patched to-> DM12 Panel 02/01-06 (MPO 01) <-F2B MPO12- MPO Panel 03/01 -cabled 6xLC EB to-> LC Panel 04/01-06  
    
    ${room_name}    Set Variable    TC_26
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${room_name}
    ${tree_node_location_report}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name} / 1:1 ${RACK_NAME}
       
    # 1. Add:
    # _Building 01/Floor 01/Room 01/1:1 Rack 001
    # + Add to Rack:
    # LC Panel 01, DM12 Panel 02, LC Panel 03, DM12 Panel 04, LC Panel 05
    # 2. Create Circuit as below:
    # LC Panel 01/01-06 -patched to-> DM12 Panel 02/01-06 (MPO 01) <-F2B MPO12- MPO Panel 03/01 -cabled 6xLC EB to-> LC Panel 04/01-06
    # 3. Go to Reports, Create "Cabling->Panel to Equipment Cabling" report with data as below:
    # 4. Check Result on View Report page with Location is current Building 
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
    # 4. Check Result on View Report page with Location is current Building 
    ${headers}    Set Variable    Location (Panel1),Panel (1),Module (1),Port (1),Cabled to Port,Location (Panel2),Panel (2),Module (2),Port (2)
	${values_list}    Create List
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),01,1:1 Rack 001 / Panel 3 / MPO 1 / 1-12,${tree_node_location_report},Panel 03,,01 / 1-12
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),02,1:1 Rack 001 / Panel 3 / MPO 1 / 2-11,${tree_node_location_report},Panel 03,,01 / 2-11
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),03,1:1 Rack 001 / Panel 3 / MPO 1 / 3-10,${tree_node_location_report},Panel 03,,01 / 3-10
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),04,1:1 Rack 001 / Panel 3 / MPO 1 / 4-9,${tree_node_location_report},Panel 03,,01 / 4-9
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),05,1:1 Rack 001 / Panel 3 / MPO 1 / 5-8,${tree_node_location_report},Panel 03,,01 / 5-8
	...    ${tree_node_location_report},Panel 02,Module 1A (DM12),06,1:1 Rack 001 / Panel 3 / MPO 1 / 6-7,${tree_node_location_report},Panel 03,,01 / 6-7
	...    ${tree_node_location_report},Panel 03,,01 / 1-12,1:1 Rack 001 / Panel 2 / Module 1 / 01,${tree_node_location_report},Panel 02,Module 1A (DM12),01
	...    ${tree_node_location_report},Panel 03,,01 / 2-11,1:1 Rack 001 / Panel 2 / Module 1 / 02,${tree_node_location_report},Panel 02,Module 1A (DM12),02
	...    ${tree_node_location_report},Panel 03,,01 / 3-10,1:1 Rack 001 / Panel 2 / Module 1 / 03,${tree_node_location_report},Panel 02,Module 1A (DM12),03
	...    ${tree_node_location_report},Panel 03,,01 / 4-9,1:1 Rack 001 / Panel 2 / Module 1 / 04,${tree_node_location_report},Panel 02,Module 1A (DM12),04
	...    ${tree_node_location_report},Panel 03,,01 / 5-8,1:1 Rack 001 / Panel 2 / Module 1 / 05,${tree_node_location_report},Panel 02,Module 1A (DM12),05
	...    ${tree_node_location_report},Panel 03,,01 / 6-7,1:1 Rack 001 / Panel 2 / Module 1 / 06,${tree_node_location_report},Panel 02,Module 1A (DM12),06
	...    ${tree_node_location_report},Panel 03,,01 / Pair 1,1:1 Rack 001 / Panel 4 / 01,${tree_node_location_report},Panel 04,,01
	...    ${tree_node_location_report},Panel 03,,01 / Pair 2,1:1 Rack 001 / Panel 4 / 02,${tree_node_location_report},Panel 04,,02
	...    ${tree_node_location_report},Panel 03,,01 / Pair 3,1:1 Rack 001 / Panel 4 / 03,${tree_node_location_report},Panel 04,,03
	...    ${tree_node_location_report},Panel 03,,01 / Pair 4,1:1 Rack 001 / Panel 4 / 04,${tree_node_location_report},Panel 04,,04
	...    ${tree_node_location_report},Panel 03,,01 / Pair 5,1:1 Rack 001 / Panel 4 / 05,${tree_node_location_report},Panel 04,,05
	...    ${tree_node_location_report},Panel 03,,01 / Pair 6,1:1 Rack 001 / Panel 4 / 06,${tree_node_location_report},Panel 04,,06
	...    ${tree_node_location_report},Panel 04,,01,1:1 Rack 001 / Panel 3 / MPO 1 / Pair 1,${tree_node_location_report},Panel 03,,01 / Pair 1
	...    ${tree_node_location_report},Panel 04,,02,1:1 Rack 001 / Panel 3 / MPO 1 / Pair 2,${tree_node_location_report},Panel 03,,01 / Pair 2
	...    ${tree_node_location_report},Panel 04,,03,1:1 Rack 001 / Panel 3 / MPO 1 / Pair 3,${tree_node_location_report},Panel 03,,01 / Pair 3
	...    ${tree_node_location_report},Panel 04,,04,1:1 Rack 001 / Panel 3 / MPO 1 / Pair 4,${tree_node_location_report},Panel 03,,01 / Pair 4
	...    ${tree_node_location_report},Panel 04,,05,1:1 Rack 001 / Panel 3 / MPO 1 / Pair 5,${tree_node_location_report},Panel 03,,01 / Pair 5
	...    ${tree_node_location_report},Panel 04,,06,1:1 Rack 001 / Panel 3 / MPO 1 / Pair 6,${tree_node_location_report},Panel 03,,01 / Pair 6
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
(SM-29855-27) Verify that Panel to Equipment Reports shows data correctly for new 6xLC EB in circuit:MPO24 Panel 01/01 -patched 3xMPO12-> MPO Panel 02/01-03 -cabled 6xLC EB to-> LC Panel 02/01-06  
    
    ${room_name}    Set Variable    TC_27
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${room_name}
    ${tree_node_location_report}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name} / 1:1 ${RACK_NAME}
       
    # 1. Add:
    # _Building 01/Floor 01/Room 01/1:1 Rack 001
    # + Add to Rack:
    # LC Panel 01, DM12 Panel 02, LC Panel 03, DM12 Panel 04, LC Panel 05
    # 2. Create Circuit as below:
    # MPO24 Panel 01/01 -patched 3xMPO12-> MPO Panel 02/01-03 -cabled 6xLC EB to-> LC Panel 02/01-06 
    # 3. Go to Reports, Create "Cabling->Panel to Equipment Cabling" report with data as below:
    # 4. Check Result on View Report page with Location is current Building 
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
    # 4. Check Result on View Report page with Location is current Building 
    ${headers}    Set Variable    Location (Panel1),Panel (1),Module (1),Port (1),Cabled to Port,Location (Panel2),Panel (2),Module (2),Port (2)
	${values_list}    Create List
	...    ${tree_node_location_report},Panel 02,,01 / Pair 1,1:1 Rack 001 / Panel 3 / 01,${tree_node_location_report},Panel 03,,01
	...    ${tree_node_location_report},Panel 02,,01 / Pair 2,1:1 Rack 001 / Panel 3 / 02,${tree_node_location_report},Panel 03,,02
	...    ${tree_node_location_report},Panel 02,,01 / Pair 3,1:1 Rack 001 / Panel 3 / 03,${tree_node_location_report},Panel 03,,03
	...    ${tree_node_location_report},Panel 02,,01 / Pair 4,1:1 Rack 001 / Panel 3 / 04,${tree_node_location_report},Panel 03,,04
	...    ${tree_node_location_report},Panel 02,,01 / Pair 5,1:1 Rack 001 / Panel 3 / 05,${tree_node_location_report},Panel 03,,05
	...    ${tree_node_location_report},Panel 02,,01 / Pair 6,1:1 Rack 001 / Panel 3 / 06,${tree_node_location_report},Panel 03,,06
	...    ${tree_node_location_report},Panel 03,,01,1:1 Rack 001 / Panel 2 / MPO 1 / Pair 1,${tree_node_location_report},Panel 02,,01 / Pair 1
	...    ${tree_node_location_report},Panel 03,,02,1:1 Rack 001 / Panel 2 / MPO 1 / Pair 2,${tree_node_location_report},Panel 02,,01 / Pair 2
	...    ${tree_node_location_report},Panel 03,,03,1:1 Rack 001 / Panel 2 / MPO 1 / Pair 3,${tree_node_location_report},Panel 02,,01 / Pair 3
	...    ${tree_node_location_report},Panel 03,,04,1:1 Rack 001 / Panel 2 / MPO 1 / Pair 4,${tree_node_location_report},Panel 02,,01 / Pair 4
	...    ${tree_node_location_report},Panel 03,,05,1:1 Rack 001 / Panel 2 / MPO 1 / Pair 5,${tree_node_location_report},Panel 02,,01 / Pair 5
	...    ${tree_node_location_report},Panel 03,,06,1:1 Rack 001 / Panel 2 / MPO 1 / Pair 6,${tree_node_location_report},Panel 02,,01 / Pair 6
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]