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
${FLOOR_NAME}    F2B Cabling
${RACK_NAME}    Rack 001
${RESTORE_FILE_NAME}    DB SM-29855.bak
${REPORT_NAME}    Front to Back Cabling	

*** Test Cases ***
(SM-29855-09) Verify that F2B Cabling Reports shows data correctly for new 6xLC EB in circuit:_LC Switch 01/01-06 <-cabled 6xLC EB to- MPO Panel 01/01 -F2B Cabling 6x LC EB to-> LC Switch 02/01-06
    [Tags]    Sanity
    ${room_name}    Set Variable    TC_09
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${room_name}
    
    # 1. Add:
    # _Building 01/Floor 01/Room 01/1:1 Rack 001
    # + Add to Rack:
    # _LC Switch 01
    # _ MPO Panel 01
    # _LC Switch 02
    # 2. Create Circuit as below:
    # _LC Switch 01/01-06 <-cabled 6xLC EB to- MPO Panel 01/01 -F2B Cabling 6x LC EB to-> LC Switch 02/01-06
    # 3. Go to Reports, Create "Cabling-> Front to Back Cabling" report with data as below:
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
    # 4. Check Result on View Report page with Location is current Building 
    ${headers}    Set Variable    Site,Building,Floor,Room,Rack Position (1),Rack Name (1),Panel (1),Port Name (1),Status (1),Rack Position (2),Rack Name (2),Panel (2),Port Name (2),Status (2)
	${values_list}    Create List
	...    Site,SM-29855,F2B Cabling,TC_09,1,Rack 001,Panel 01,01 / Pair 1,In Use,1,Rack 001,Panel 02,Module 1A (Pass-Through) / 01,Available
	...    Site,SM-29855,F2B Cabling,TC_09,1,Rack 001,Panel 01,01 / Pair 2,In Use,1,Rack 001,Panel 02,Module 1A (Pass-Through) / 02,Available
	...    Site,SM-29855,F2B Cabling,TC_09,1,Rack 001,Panel 01,01 / Pair 3,In Use,1,Rack 001,Panel 02,Module 1A (Pass-Through) / 03,Available
	...    Site,SM-29855,F2B Cabling,TC_09,1,Rack 001,Panel 01,01 / Pair 4,In Use,1,Rack 001,Panel 02,Module 1A (Pass-Through) / 04,Available
	...    Site,SM-29855,F2B Cabling,TC_09,1,Rack 001,Panel 01,01 / Pair 5,In Use,1,Rack 001,Panel 02,Module 1A (Pass-Through) / 05,Available
	...    Site,SM-29855,F2B Cabling,TC_09,1,Rack 001,Panel 01,01 / Pair 6,In Use,1,Rack 001,Panel 02,Module 1A (Pass-Through) / 06,Available
	...    Site,SM-29855,F2B Cabling,TC_09,1,Rack 001,Panel 01,02,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_09,1,Rack 001,Panel 01,03,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_09,1,Rack 001,Panel 01,04,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_09,1,Rack 001,Panel 01,05,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_09,1,Rack 001,Panel 01,06,Available,,,,, 
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

(SM-29855-10) Verify that F2B Cabling Reports shows data correctly for new 6xLC EB in circuit:_LC Switch 01/01-06 <-cabled 6xLC EB to- MPO Panel 01/01 -F2B Cabling 6x LC EB to-> LC Switch 02/01-06
    
    ${room_name}    Set Variable    TC_10
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${room_name}
    
    # 1. Add:
    # _Building 01/Floor 01/Room 01/1:1 Rack 001
    # + Add to Rack:
    # _LC Switch 01
    # _ MPO Panel 01
    # _LC Switch 02
    # 2. Create Circuit as below:
    # _LC Switch 01/01-06 <-cabled 6xLC EB to- MPO Panel 01/01 -F2B Cabling 6x LC EB to-> LC Switch 02/01-06
    # 3. Go to Reports, Create "Cabling-> Front to Back Cabling" report with data as below:
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
    # 4. Check Result on View Report page with Location is current Building 
    ${headers}    Set Variable    Site,Building,Floor,Room,Rack Position (1),Rack Name (1),Panel (1),Port Name (1),Status (1),Rack Position (2),Rack Name (2),Panel (2),Port Name (2),Status (2)
	${values_list}    Create List
	...    Site,SM-29855,F2B Cabling,TC_10,1,Rack 001,Panel 01,01 / Pair 1,In Use,1,Rack 001,Panel 02,01,In Use
	...    Site,SM-29855,F2B Cabling,TC_10,1,Rack 001,Panel 01,01 / Pair 2,In Use,1,Rack 001,Panel 02,02,In Use
	...    Site,SM-29855,F2B Cabling,TC_10,1,Rack 001,Panel 01,01 / Pair 3,In Use,1,Rack 001,Panel 02,03,In Use
	...    Site,SM-29855,F2B Cabling,TC_10,1,Rack 001,Panel 01,01 / Pair 4,In Use,1,Rack 001,Panel 02,04,In Use
	...    Site,SM-29855,F2B Cabling,TC_10,1,Rack 001,Panel 01,01 / Pair 5,In Use,1,Rack 001,Panel 02,05,In Use
	...    Site,SM-29855,F2B Cabling,TC_10,1,Rack 001,Panel 01,01 / Pair 6,In Use,1,Rack 001,Panel 02,06,In Use
	...    Site,SM-29855,F2B Cabling,TC_10,1,Rack 001,Panel 01,02,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_10,1,Rack 001,Panel 01,03,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_10,1,Rack 001,Panel 01,04,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_10,1,Rack 001,Panel 01,05,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_10,1,Rack 001,Panel 01,06,Available,,,,, 
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
(SM-29855-11) Verify that F2B Cabling Reports shows data correctly for new 6xLC EB in circuit:LC Panel 01/01-04 <- cabled to- MPO Panel 02/01 -F2B Cabling 6xLC EB-> LC Panel 03/01-06
    
    ${room_name}    Set Variable    TC_11
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${room_name}
    
    # 1. Add:
    # _Building 01/Floor 01/Room 01/1:1 Rack 001
    # + Add to Rack:
    # _LC Switch 01
    # _ MPO Panel 01
    # _LC Switch 02
    # 2. Create Circuit as below:
    # _LC Panel 01/01-04 <- cabled to- MPO Panel 02/01 -F2B Cabling 6xLC EB-> LC Panel 03/01-06
    # 3. Go to Reports, Create "Cabling-> Front to Back Cabling" report with data as below:
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
    # 4. Check Result on View Report page with Location is current Building 
    ${headers}    Set Variable    Site,Building,Floor,Room,Rack Position (1),Rack Name (1),Panel (1),Port Name (1),Status (1),Rack Position (2),Rack Name (2),Panel (2),Port Name (2),Status (2)
	${values_list}    Create List
	...    Site,SM-29855,F2B Cabling,TC_11,1,Rack 001,Panel 02,01 / Pair 1,In Use,1,Rack 001,Panel 01,01,Available
	...    Site,SM-29855,F2B Cabling,TC_11,1,Rack 001,Panel 02,01 / Pair 2,In Use,1,Rack 001,Panel 01,02,Available
	...    Site,SM-29855,F2B Cabling,TC_11,1,Rack 001,Panel 02,01 / Pair 3,In Use,1,Rack 001,Panel 01,03,Available
	...    Site,SM-29855,F2B Cabling,TC_11,1,Rack 001,Panel 02,01 / Pair 4,In Use,1,Rack 001,Panel 01,04,Available
	...    Site,SM-29855,F2B Cabling,TC_11,1,Rack 001,Panel 02,01 / Pair 5,In Use,1,Rack 001,Panel 03,05,Available
	...    Site,SM-29855,F2B Cabling,TC_11,1,Rack 001,Panel 02,01 / Pair 6,In Use,1,Rack 001,Panel 03,06,Available
	...    Site,SM-29855,F2B Cabling,TC_11,1,Rack 001,Panel 02,02,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_11,1,Rack 001,Panel 02,03,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_11,1,Rack 001,Panel 02,04,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_11,1,Rack 001,Panel 02,05,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_11,1,Rack 001,Panel 02,06,Available,,,,, 
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
(SM-29855-12) Verify that F2B Cabling Reports shows data correctly for new 6xLC EB in circuit:MPO24 Switch 01/01 -cabled Trifurcase to -> MPO Panel 01/01-03 -F2B Cabling 6x LC EB to-> LC Panel 02/01-06
    
    ${room_name}    Set Variable    TC_12
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${room_name}
    
    # 1. Add:
    # _Building 01/Floor 01/Room 01/1:1 Rack 001
    # + Add to Rack:
    # _LC Switch 01
    # _ MPO Panel 01
    # _LC Switch 02
    # 2. Create Circuit as below:
    # _MPO24 Switch 01/01 -cabled Trifurcase to -> MPO Panel 01/01-03 -F2B Cabling 6x LC EB to-> LC Panel 02/01-06
    # 3. Go to Reports, Create "Cabling-> Front to Back Cabling" report with data as below:
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
    # 4. Check Result on View Report page with Location is current Building 
    ${headers}    Set Variable    Site,Building,Floor,Room,Rack Position (1),Rack Name (1),Panel (1),Port Name (1),Status (1),Rack Position (2),Rack Name (2),Panel (2),Port Name (2),Status (2)
	${values_list}    Create List
	...    Site,SM-29855,F2B Cabling,TC_12,1,Rack 001,Panel 01,01 / Pair 1,In Use,1,Rack 001,Panel 02,01,Available
	...    Site,SM-29855,F2B Cabling,TC_12,1,Rack 001,Panel 01,01 / Pair 2,In Use,1,Rack 001,Panel 02,02,Available
	...    Site,SM-29855,F2B Cabling,TC_12,1,Rack 001,Panel 01,01 / Pair 3,In Use,1,Rack 001,Panel 02,03,Available
	...    Site,SM-29855,F2B Cabling,TC_12,1,Rack 001,Panel 01,01 / Pair 4,In Use,1,Rack 001,Panel 02,04,Available
	...    Site,SM-29855,F2B Cabling,TC_12,1,Rack 001,Panel 01,01 / Pair 5,In Use,1,Rack 001,Panel 02,05,Available
	...    Site,SM-29855,F2B Cabling,TC_12,1,Rack 001,Panel 01,01 / Pair 6,In Use,1,Rack 001,Panel 02,06,Available
	...    Site,SM-29855,F2B Cabling,TC_12,1,Rack 001,Panel 01,02,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_12,1,Rack 001,Panel 01,03,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_12,1,Rack 001,Panel 01,04,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_12,1,Rack 001,Panel 01,05,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_12,1,Rack 001,Panel 01,06,Available,,,,, 
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
(SM-29855-13) Verify that F2B Cabling Reports shows data correctly for new 6xLC EB in circuit:MPO12 Panel 03/01 -F2B Cabling 6xLC EB->LC Panel 01/01-06 -F2B Cabling 6x EB to-> DM08 Panel 02/(MPO 01)/01-04 
    
    ${room_name}    Set Variable    TC_13
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${room_name}
    
    # 1. Add:
    # _Building 01/Floor 01/Room 01/1:1 Rack 001
    # + Add to Rack:
    # _LC Switch 01
    # _ MPO Panel 01
    # _LC Switch 02
    # 2. Create Circuit as below:
    # _MPO12 Panel 03/01 -F2B Cabling 6xLC EB->LC Panel 01/01-06 -F2B Cabling 6x EB to-> DM08 Panel 02/(MPO 01)/01-04 
    # 3. Go to Reports, Create "Cabling-> Front to Back Cabling" report with data as below:
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
    # 4. Check Result on View Report page with Location is current Building 
    ${headers}    Set Variable    Site,Building,Floor,Room,Rack Position (1),Rack Name (1),Panel (1),Port Name (1),Status (1),Rack Position (2),Rack Name (2),Panel (2),Port Name (2),Status (2)
	${values_list}    Create List
	...    Site,SM-29855,F2B Cabling,TC_13,1,Rack 001,Panel 03,01 / Pair 1,In Use,1,Rack 001,Panel 01,01,In Use
	...    Site,SM-29855,F2B Cabling,TC_13,1,Rack 001,Panel 03,01 / Pair 2,In Use,1,Rack 001,Panel 01,02,In Use
	...    Site,SM-29855,F2B Cabling,TC_13,1,Rack 001,Panel 03,01 / Pair 3,In Use,1,Rack 001,Panel 01,03,In Use
	...    Site,SM-29855,F2B Cabling,TC_13,1,Rack 001,Panel 03,01 / Pair 4,In Use,1,Rack 001,Panel 01,04,In Use
	...    Site,SM-29855,F2B Cabling,TC_13,1,Rack 001,Panel 03,01 / Pair 5,In Use,1,Rack 001,Panel 01,05,In Use
	...    Site,SM-29855,F2B Cabling,TC_13,1,Rack 001,Panel 03,01 / Pair 6,In Use,1,Rack 001,Panel 01,06,In Use
	...    Site,SM-29855,F2B Cabling,TC_13,1,Rack 001,Panel 03,02,Available,,,,, 
    ${rows_list}    Create List    1    2    3    4    5    6    7
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
(SM-29855-14) Verify that F2B Cabling Reports shows data correctly for new 6xLC EB in circuit:MPO24 Switch 01/01 -cabled 3xMPO12 to-> MPO Panel 01/01,02,03 -F2B Cabling 6xLC EB to-> LC Panel 02/01-18 
    
    ${room_name}    Set Variable    TC_14
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${room_name}
    
    # 1. Add:
    # _Building 01/Floor 01/Room 01/1:1 Rack 001
    # + Add to Rack:
    # _LC Switch 01
    # _ MPO Panel 01
    # _LC Switch 02
    # 2. Create Circuit as below:
    # _MPO12 Panel 03/01 -F2B Cabling 6xLC EB->LC Panel 01/01-06 -F2B Cabling 6x EB to-> DM08 Panel 02/(MPO 01)/01-04 
    # 3. Go to Reports, Create "Cabling-> Front to Back Cabling" report with data as below:
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
    # 4. Check Result on View Report page with Location is current Building 
    ${headers}    Set Variable    Site,Building,Floor,Room,Rack Position (1),Rack Name (1),Panel (1),Port Name (1),Status (1),Rack Position (2),Rack Name (2),Panel (2),Port Name (2),Status (2)
	${values_list}    Create List
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,01 / Pair 1,In Use,1,Rack 001,Panel 02,01,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,01 / Pair 2,In Use,1,Rack 001,Panel 02,02,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,01 / Pair 3,In Use,1,Rack 001,Panel 02,03,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,01 / Pair 4,In Use,1,Rack 001,Panel 02,04,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,01 / Pair 5,In Use,1,Rack 001,Panel 02,05,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,01 / Pair 6,In Use,1,Rack 001,Panel 02,06,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,02 / Pair 1,In Use,1,Rack 001,Panel 02,07,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,02 / Pair 2,In Use,1,Rack 001,Panel 02,08,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,02 / Pair 3,In Use,1,Rack 001,Panel 02,09,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,02 / Pair 4,In Use,1,Rack 001,Panel 02,10,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,02 / Pair 5,In Use,1,Rack 001,Panel 02,11,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,02 / Pair 6,In Use,1,Rack 001,Panel 02,12,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,03 / Pair 1,In Use,1,Rack 001,Panel 02,13,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,03 / Pair 2,In Use,1,Rack 001,Panel 02,14,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,03 / Pair 3,In Use,1,Rack 001,Panel 02,15,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,03 / Pair 4,In Use,1,Rack 001,Panel 02,16,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,03 / Pair 5,In Use,1,Rack 001,Panel 02,17,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,03 / Pair 6,In Use,1,Rack 001,Panel 02,18,Available
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,04,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,05,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_14,1,Rack 001,Panel 01,06,Available,,,,, 
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18    19    20    21
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

(SM-29855-15) Verify that F2B Cabling Reports shows data correctly for new 6xLC EB in circuit:MPO12 Switch 01/01 -cabled to-> MPO12 Panel 01/01-06 -F2B cabling 6xLC EB to-> LC Panel 02/01-06 -F2B cabling 6xLC EB to-> DM12 Panel 03/01-06 -patchig to-> LC Server 01/01-06
    
    ${room_name}    Set Variable    TC_15
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${room_name}
    
    # 1. Add:
    # _Building 01/Floor 01/Room 01/1:1 Rack 001
    # + Add to Rack:
    # _LC Switch 01
    # _ MPO Panel 01
    # _LC Switch 02
    # 2. Create Circuit as below:
    # _MPO12 Switch 01/01 -cabled to-> MPO12 Panel 01/01-06 -F2B cabling 6xLC EB to-> LC Panel 02/01-06  -F2B cabling 6xLC EB to-> DM12 Panel 03/01-06 -patchig to-> LC Server 01/01-06
    # 3. Go to Reports, Create "Cabling-> Front to Back Cabling" report with data as below:
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_room}    clickViewBtn=${True}
    # 4. Check Result on View Report page with Location is current Building 
    ${headers}    Set Variable    Site,Building,Floor,Room,Rack Position (1),Rack Name (1),Panel (1),Port Name (1),Status (1),Rack Position (2),Rack Name (2),Panel (2),Port Name (2),Status (2)
	${values_list}    Create List
	...    Site,SM-29855,F2B Cabling,TC_15,1,Rack 001,Panel 01,01 / Pair 1,In Use,1,Rack 001,Panel 02,01,In Use
	...    Site,SM-29855,F2B Cabling,TC_15,1,Rack 001,Panel 01,01 / Pair 2,In Use,1,Rack 001,Panel 02,02,In Use
	...    Site,SM-29855,F2B Cabling,TC_15,1,Rack 001,Panel 01,01 / Pair 3,In Use,1,Rack 001,Panel 02,03,In Use
	...    Site,SM-29855,F2B Cabling,TC_15,1,Rack 001,Panel 01,01 / Pair 4,In Use,1,Rack 001,Panel 02,04,In Use
	...    Site,SM-29855,F2B Cabling,TC_15,1,Rack 001,Panel 01,01 / Pair 5,In Use,1,Rack 001,Panel 02,05,In Use
	...    Site,SM-29855,F2B Cabling,TC_15,1,Rack 001,Panel 01,01 / Pair 6,In Use,1,Rack 001,Panel 02,06,In Use
	...    Site,SM-29855,F2B Cabling,TC_15,1,Rack 001,Panel 01,02,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_15,1,Rack 001,Panel 01,03,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_15,1,Rack 001,Panel 01,04,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_15,1,Rack 001,Panel 01,05,Available,,,,, 
	...    Site,SM-29855,F2B Cabling,TC_15,1,Rack 001,Panel 01,06,Available,,,,, 
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]