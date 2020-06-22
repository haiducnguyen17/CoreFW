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

Force Tags    SM-29855
Default Tags    Reports

*** Variables ***
${BUILDING_NAME}    SM-29855
${FLOOR_NAME}    Connection in Rooms
${RACK_GROUP_NAME}    Rack Group 01
${RACK_NAME}    Rack 001
${FACEPLATE_NAME}    Faceplate 01
${CP_NAME}    Consolidation Point 01
${PANEL_NAME}    Panel 01
${PANEL_NAME_2}    Panel 02
${PANEL_NAME_3}    Panel 03
${DEVICE_1}    Device 01
${DEVICE_2}    Device 02
${DEVICE_3}    Device 03
${DEVICE_4}    Device 04
${DEVICE_5}    Device 05
${DEVICE_6}    Device 06
${DEVICE_7}    Device 07
${Device 8}    Device 08
${RESTORE_FILE_NAME}    DB SM-29855.bak

*** Test Cases ***
SM-29855_TC01,02,03,04,05,06,07,08_Verify that Connections in Rooms Reports and Panel-to-Faceplate/Consolidation Point Cabling Reports shows data correctly for new 6xLC EB in circuit
    
    [Tags]    Sanity
    
    ################### Connections in Rooms Reports ###################
    
    ${report_name}    Set Variable    Connection in Rooms_TC 01
    ${switch_tc1}    Set Variable    Switch TC_01
    ${switch_tc2}    Set Variable    Switch TC_02
    ${switch_tc3}    Set Variable    Switch TC_03
    ${switch_tc4}    Set Variable    Switch TC_04
    ${switch_tc5}    Set Variable    Switch TC_05
    ${switch_tc6}    Set Variable    Switch TC_06
    ${switch_tc7}    Set Variable    Switch TC_07
    ${switch_tc8}    Set Variable    Switch TC_08
    ${card_3}    Set Variable    Card 03
    ${card_4}    Set Variable    Card 04
    ${gbic_slot_2}    Set Variable    GBIC Slot 02
    ${gbic_slot_3}    Set Variable    GBIC Slot 03
    ${gbic_slot_4}    Set Variable    GBIC Slot 04
    ${gbic_slot_28}    Set Variable   GBIC Slot 28
    
    # 1. Add:
	# _Building 01/Floor 01/Room 01 -> 8/1:1 Rack 001
	# 2. Create Circuit as below in each Room
	# _MPO12 Switch 01/01 -cabled 6xLC EB to-> LC Panel 01/01->06 -patched to->LC Panel 02/01-06 -cabled to-> Faceplate 01/01-06 -patched to-> Manual Devices
	# _MPO12 Switch 01 -patched 6xLC EB to ->LC Panel 01/01-06 <- cabled 6xLC EB to - DM12 Panel 02/ 01-06 -patched to-> LC Panel 03/01-06 -cabled to-> to Faceplate 01/01-06  -patched to-> Discovered Devices
	# _MPO12 Switch 01/01 -patched to-> MPO Panel 01/01 -cabled 6xLC EB -> LC Panel 02/01-06 -patched to-> LC Panel 03/01-06 -cable to-> Faceplate 01/01-06 -patched to-> Manual Devices
	# _LC Switch 01/01-04 <-patched 4x to- MPO Panel 01 -cabled 6xLC EB to-> LC Panel 02/01-06 -patched to-> LC Panel 03/01-06 -cabled to-> Faceplate 01/01-06 -connect to-> Discovered Devices
	# _LC Switch 01/01-06 <-patched 6xLC EB to- MPO Panel 01 -cabled 6xLC EB to-> LC Panel 02/01-06 -patched to-> LC Panel 03/01-06 -cabled to-> Faceplate 01/01-06 -connect to-> Discovered Devices
	# _MPO12 Switch 01 -patched 6xLC EB to ->LC Panel 01/01-06 <- cabled 6xLC EB to - DM08 Panel 02/ 01-06 -patched to-> LC Panel 03/01-04 -cabled to-> to Consolidation Point 01/01-04 -> cabled to - Faceplate 01/01-04  -patched to-> Manual Devices
	# _MPO12 Switch 01 -patched 6xLC EB to ->LC Panel 01/01-06 <- cabled 6xLC EB to - DM08 Panel 02/ 01-04 -patched to-> LC Panel 03/01-04 -cabled to-> to Faceplate 01/01-04  -patched to-> Manual Devices
	# _MPO24 Switch 01/01-06 -Patched Trifurcase to-> MPO Panel 01/01-03 -cabled 6xLC EB to-> LC Panel 02/01-06 -patched to-> LC Panel 03/01-06 -cabled to-> Faceplate 01/01-06 -patched to-> manual Devices
	# 3. Go to Reports, Create "Location-> Connection in Room" report with data as below:
    # _Switch. Card, GBIC  Slot, Port, Patched to Port, Faceplate Name, Outlet, Device Name, Device Type, IP Address
    # 4.Check Result on View Report page with Location is current Building
    
    Select Main Menu    ${Reports}
    View Report    ${report_name}
    Select Filter For Report    selectLocationType=Check    treeNode=${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}    clickViewBtn=${True}
    Sort View Report Table By Column Name    Switch    typeSort=desc
    Sort View Report Table By Column Name    Switch    typeSort=asc
    ${headers}    Set Variable    Switch,Card,GBIC Slot,Port,Patched to Port,Faceplate Name,Outlet,Device Name,Device Type,IP Address
    ${values_list}    Create List
    ...    ${switch_tc1},,,${Port 01} / ${A1},,${FACEPLATE_NAME},${Port 01},${DEVICE_1},${Computer},
    ...    ${switch_tc1},,,${Port 01} / ${A1},,${FACEPLATE_NAME},${Port 02},${DEVICE_2},${Fax},
    ...    ${switch_tc1},,,${Port 01} / ${A1},,${FACEPLATE_NAME},${Port 03},${DEVICE_3},${Phone},
    ...    ${switch_tc1},,,${Port 01} / ${A1},,${FACEPLATE_NAME},${Port 04},${DEVICE_4},${Printer},
    ...    ${switch_tc1},,,${Port 01} / ${A1},,${FACEPLATE_NAME},${Port 05},${DEVICE_5},${Networked Device},
    ...    ${switch_tc1},,,${Port 01} / ${A1},,${FACEPLATE_NAME},${Port 06},${DEVICE_6},${Access Point},
    ...    ${switch_tc2},,${gbic_slot_28},${Port 01} / ${A1},${PANEL_NAME} / ${Port 01} / ${Pair 1},${FACEPLATE_NAME},${Port 01},${DEVICE_1},${Networked Device},
    ...    ${switch_tc2},,${gbic_slot_28},${Port 01} / ${A1},${PANEL_NAME} / ${Port 02} / ${Pair 2},${FACEPLATE_NAME},${Port 02},${DEVICE_2},${Networked Device},
    ...    ${switch_tc2},,${gbic_slot_28},${Port 01} / ${A1},${PANEL_NAME} / ${Port 03} / ${Pair 3},${FACEPLATE_NAME},${Port 03},${DEVICE_3},${Networked Device},
    ...    ${switch_tc2},,${gbic_slot_28},${Port 01} / ${A1},${PANEL_NAME} / ${Port 04} / ${Pair 4},${FACEPLATE_NAME},${Port 04},${DEVICE_4},${Networked Device},
    ...    ${switch_tc3},,,${Port 01},${PANEL_NAME} / ${Port 01} / /${A1},${FACEPLATE_NAME},${Port 01},${DEVICE_1},${Computer},
    ...    ${switch_tc3},,,${Port 01},${PANEL_NAME} / ${Port 01} / /${A1},${FACEPLATE_NAME},${Port 02},${DEVICE_2},${Fax},
    ...    ${switch_tc3},,,${Port 01},${PANEL_NAME} / ${Port 01} / /${A1},${FACEPLATE_NAME},${Port 03},${DEVICE_3},${Phone},
    ...    ${switch_tc3},,,${Port 01},${PANEL_NAME} / ${Port 01} / /${A1},${FACEPLATE_NAME},${Port 04},${DEVICE_4},${Printer},
    ...    ${switch_tc3},,,${Port 01},${PANEL_NAME} / ${Port 01} / /${A1},${FACEPLATE_NAME},${Port 05},${DEVICE_5},${Networked Device},
    ...    ${switch_tc3},,,${Port 01},${PANEL_NAME} / ${Port 01} / /${A1},${FACEPLATE_NAME},${Port 06},${DEVICE_6},${Access Point},
    ...    ${switch_tc4},,,${Port 01} / ${1-1},${PANEL_NAME} / ${Port 01} / ${A1},${FACEPLATE_NAME},${Port 01},${DEVICE_1},${Networked Device},
    ...    ${switch_tc4},,,${Port 02} / ${2-2},${PANEL_NAME} / ${Port 01} / ${A1},${FACEPLATE_NAME},${Port 02},${DEVICE_2},${Networked Device},
    ...    ${switch_tc4},,,${Port 03} / ${3-3},${PANEL_NAME} / ${Port 01} / ${A1},${FACEPLATE_NAME},${Port 03},${DEVICE_3},${Networked Device},
    ...    ${switch_tc4},,,${Port 04} / ${4-4},${PANEL_NAME} / ${Port 01} / ${A1},${FACEPLATE_NAME},${Port 04},${DEVICE_4},${Networked Device},
    ...    ${switch_tc5},${card_3},${gbic_slot_2},${Port 01} / ${Pair 1},${PANEL_NAME} / ${Port 01} / ${A1},${FACEPLATE_NAME},${Port 01},${DEVICE_1},${Networked Device},10.49.16.6
    ...    ${switch_tc5},${card_3},${gbic_slot_2},${Port 01} / ${Pair 1},${PANEL_NAME} / ${Port 01} / ${A1},${FACEPLATE_NAME},${Port 01},${DEVICE_2},${Networked Device},10.49.16.4
    ...    ${switch_tc5},${card_3},${gbic_slot_3},${Port 01} / ${Pair 2},${PANEL_NAME} / ${Port 01} / ${A1},${FACEPLATE_NAME},${Port 02},${DEVICE_3},${Networked Device},10.49.28.6
    ...    ${switch_tc5},${card_3},${gbic_slot_3},${Port 01} / ${Pair 2},${PANEL_NAME} / ${Port 01} / ${A1},${FACEPLATE_NAME},${Port 02},${DEVICE_4},${Networked Device},10.49.28.4
    ...    ${switch_tc5},${card_3},${gbic_slot_4},${Port 01} / ${Pair 3},${PANEL_NAME} / ${Port 01} / ${A1},${FACEPLATE_NAME},${Port 03},${DEVICE_5},${Networked Device},10.49.4.108
    ...    ${switch_tc5},${card_3},${gbic_slot_4},${Port 01} / ${Pair 3},${PANEL_NAME} / ${Port 01} / ${A1},${FACEPLATE_NAME},${Port 03},${DEVICE_6},${Networked Device},10.49.4.107
    ...    ${switch_tc5},${card_4},${gbic_slot_2},${Port 01} / ${Pair 4},${PANEL_NAME} / ${Port 01} / ${A1},${FACEPLATE_NAME},${Port 04},${DEVICE_7},${Networked Device},10.49.16.5
    ...    ${switch_tc5},${card_4},${gbic_slot_3},${Port 01} / ${Pair 5},${PANEL_NAME} / ${Port 01} / ${A1},${FACEPLATE_NAME},${Port 05},${DEVICE_8},${Networked Device},10.49.28.5
    ...    ${switch_tc6},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 01} / ${Pair 1},${FACEPLATE_NAME},${Port 01},${DEVICE_1},${Computer},
    ...    ${switch_tc6},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 02} / ${Pair 2},${FACEPLATE_NAME},${Port 02},${DEVICE_2},${Computer},
    ...    ${switch_tc6},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 03} / ${Pair 3},${FACEPLATE_NAME},${Port 03},${DEVICE_3},${Computer},
    ...    ${switch_tc6},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 04} / ${Pair 4},${FACEPLATE_NAME},${Port 04},${DEVICE_4},${Computer},
    ...    ${switch_tc7},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 01} / ${Pair 1},${FACEPLATE_NAME},${Port 01},${DEVICE_1},${Computer},
    ...    ${switch_tc7},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 02} / ${Pair 2},${FACEPLATE_NAME},${Port 02},${DEVICE_2},${Computer},
    ...    ${switch_tc7},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 03} / ${Pair 3},${FACEPLATE_NAME},${Port 03},${DEVICE_3},${Computer},
    ...    ${switch_tc7},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 04} / ${Pair 4},${FACEPLATE_NAME},${Port 04},${DEVICE_4},${Computer},
    ...    ${switch_tc8},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 01} / ${B1}/${A1},${FACEPLATE_NAME},${Port 01},${DEVICE_1},${Computer},
    ...    ${switch_tc8},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 01} / ${B1}/${A1},${FACEPLATE_NAME},${Port 02},${DEVICE_2},${Fax},
    ...    ${switch_tc8},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 01} / ${B1}/${A1},${FACEPLATE_NAME},${Port 03},${DEVICE_3},${Phone},
    ...    ${switch_tc8},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 01} / ${B1}/${A1},${FACEPLATE_NAME},${Port 04},${DEVICE_4},${Printer},
    ...    ${switch_tc8},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 01} / ${B1}/${A1},${FACEPLATE_NAME},${Port 05},${DEVICE_5},${Networked Device},
    ...    ${switch_tc8},,,${Port 01} / ${A1},${PANEL_NAME} / ${Port 01} / ${B1}/${A1},${FACEPLATE_NAME},${Port 06},${DEVICE_6},${Access Point},
    
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29    30    31    32    33    34    35    36    37    38    39    40    41    42
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

    ################### Panel-to-Faceplate/Consolidation Point Cabling Reports ###################
    
    ${report_name_2}    Set Variable    Panel-to-Faceplate_TC 01
    ${room_name_1_2}    Set Variable    TC_01
    ${room_name_2_2}    Set Variable    TC_02
    ${room_name_3_2}    Set Variable    TC_03
    ${room_name_4_2}    Set Variable    TC_04
    ${room_name_5_2}    Set Variable    TC_05
    ${room_name_6_2}    Set Variable    TC_06
    ${room_name_7_2}    Set Variable    TC_07
    ${room_name_8_2}    Set Variable    TC_08
    ${panel_3_2}    Set Variable    Panel 3
    ${panel_4_2}    Set Variable    Panel 4
    ${1_2}    Set Variable    1
    ${2_2}    Set Variable    2
    ${3_2}    Set Variable    3
    ${4_2}    Set Variable    4
    ${5_2}    Set Variable    5
    ${6_2}    Set Variable    6
    ${tree_node_room1_report_2}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_1_2}
    ${tree_node_room2_report_2}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_2_2}
    ${tree_node_room3_report_2}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_3_2}
    ${tree_node_room4_report_2}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_4_2}
    ${tree_node_room5_report_2}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_5_2}
    ${tree_node_room6_report_2}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_6_2}
    ${tree_node_room7_report_2}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_7_2}
    ${tree_node_room8_report_2}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_8_2}
    
    # 1. Add:
	# _Building 01/Floor 01/Room 01 -> 8/1:1 Rack 001
	# 2. Create Circuit as below in each Room
	# _MPO12 Switch 01/01 -cabled 6xLC EB to-> LC Panel 01/01->06 -patched to->LC Panel 02/01-06 -cabled to-> Faceplate 01/01-06 -patched to-> Manual Devices
	# _MPO12 Switch 01 -patched 6xLC EB to ->LC Panel 01/01-06 <- cabled 6xLC EB to - DM12 Panel 02/ 01-06 -patched to-> LC Panel 03/01-06 -cabled to-> to Faceplate 01/01-06  -patched to-> Discovered Devices
	# _MPO12 Switch 01/01 -patched to-> MPO Panel 01/01 -cabled 6xLC EB -> LC Panel 02/01-06 -patched to-> LC Panel 03/01-06 -cable to-> Faceplate 01/01-06 -patched to-> Manual Devices
	# _LC Switch 01/01-04 <-patched 4x to- MPO Panel 01 -cabled 6xLC EB to-> LC Panel 02/01-06 -patched to-> LC Panel 03/01-06 -cabled to-> Faceplate 01/01-06 -connect to-> Discovered Devices
	# _LC Switch 01/01-06 <-patched 6xLC EB to- MPO Panel 01 -cabled 6xLC EB to-> LC Panel 02/01-06 -patched to-> LC Panel 03/01-06 -cabled to-> Faceplate 01/01-06 -connect to-> Discovered Devices
	# _MPO12 Switch 01 -patched 6xLC EB to ->LC Panel 01/01-06 <- cabled 6xLC EB to - DM08 Panel 02/ 01-06 -patched to-> LC Panel 03/01-04 -cabled to-> to Consolidation Point 01/01-04 -> cabled to - Faceplate 01/01-04  -patched to-> Manual Devices
	# _MPO12 Switch 01 -patched 6xLC EB to ->LC Panel 01/01-06 <- cabled 6xLC EB to - DM08 Panel 02/ 01-04 -patched to-> LC Panel 03/01-04 -cabled to-> to Faceplate 01/01-04  -patched to-> Manual Devices
	# _MPO24 Switch 01/01-06 -Patched Trifurcase to-> MPO Panel 01/01-03 -cabled 6xLC EB to-> LC Panel 02/01-06 -patched to-> LC Panel 03/01-06 -cabled to-> Faceplate 01/01-06 -patched to-> manual Devices
	# 3. Go to Reports, Create "Cabling->>Panel-to-Faceplate/Consolidation Point Cabling" report with data as below:
	# _Location, Panel, Module, Port, Equipment Position, Cabled to Outlet, CP, Consolidation Point Port
	# 4. Check Result on View Report page with Location is current Building 
    
    Select Main Menu    ${Reports}
    View Report    ${report_name_2}
    Select Filter For Report    selectLocationType=Check    treeNode=${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}    clickViewBtn=${True} 
    Sort View Report Table By Column Name   Location    typeSort=desc
    Sort View Report Table By Column Name    Location    typeSort=asc
    ${headers}    Set Variable    Location,Panel,Module,Port Type,Port,Equipment Position,Port Position,Cabled to Outlet,Faceplate,CP,Consolidation Point Port
    ${values_list}    Create List
    ...    ${tree_node_room1_report_2},${PANEL_NAME_2},,${LC},${Port 01},${panel_3_2},${1_2},${room_name_1_2} / ${FACEPLATE_NAME} / ${Port 01},${FACEPLATE_NAME},,
    ...    ${tree_node_room1_report_2},${PANEL_NAME_2},,${LC},${Port 02},${panel_3_2},${2_2},${room_name_1_2} / ${FACEPLATE_NAME} / ${Port 02},${FACEPLATE_NAME},,
    ...    ${tree_node_room1_report_2},${PANEL_NAME_2},,${LC},${Port 03},${panel_3_2},${3_2},${room_name_1_2} / ${FACEPLATE_NAME} / ${Port 03},${FACEPLATE_NAME},,
    ...    ${tree_node_room1_report_2},${PANEL_NAME_2},,${LC},${Port 04},${panel_3_2},${4_2},${room_name_1_2} / ${FACEPLATE_NAME} / ${Port 04},${FACEPLATE_NAME},,
    ...    ${tree_node_room1_report_2},${PANEL_NAME_2},,${LC},${Port 05},${panel_3_2},${5_2},${room_name_1_2} / ${FACEPLATE_NAME} / ${Port 05},${FACEPLATE_NAME},,
    ...    ${tree_node_room1_report_2},${PANEL_NAME_2},,${LC},${Port 06},${panel_3_2},${6_2},${room_name_1_2} / ${FACEPLATE_NAME} / ${Port 06},${FACEPLATE_NAME},,
    ...    ${tree_node_room2_report_2},${PANEL_NAME_3},,${LC},${Port 01},${panel_3_2},${1_2},${room_name_2_2} / ${FACEPLATE_NAME} / ${Port 01},${FACEPLATE_NAME},,
    ...    ${tree_node_room2_report_2},${PANEL_NAME_3},,${LC},${Port 02},${panel_3_2},${2_2},${room_name_2_2} / ${FACEPLATE_NAME} / ${Port 02},${FACEPLATE_NAME},,
    ...    ${tree_node_room2_report_2},${PANEL_NAME_3},,${LC},${Port 03},${panel_3_2},${3_2},${room_name_2_2} / ${FACEPLATE_NAME} / ${Port 03},${FACEPLATE_NAME},,
    ...    ${tree_node_room2_report_2},${PANEL_NAME_3},,${LC},${Port 04},${panel_3_2},${4_2},${room_name_2_2} / ${FACEPLATE_NAME} / ${Port 04},${FACEPLATE_NAME},,
    ...    ${tree_node_room2_report_2},${PANEL_NAME_3},,${LC},${Port 05},${panel_3_2},${5_2},${room_name_2_2} / ${FACEPLATE_NAME} / ${Port 05},${FACEPLATE_NAME},,
    ...    ${tree_node_room2_report_2},${PANEL_NAME_3},,${LC},${Port 06},${panel_3_2},${6_2},${room_name_2_2} / ${FACEPLATE_NAME} / ${Port 06},${FACEPLATE_NAME},,
    ...    ${tree_node_room3_report_2},${PANEL_NAME_3},,${LC},${Port 01},${panel_4_2},${1_2},${room_name_3_2} / ${FACEPLATE_NAME} / ${Port 01},${FACEPLATE_NAME},,
    ...    ${tree_node_room3_report_2},${PANEL_NAME_3},,${LC},${Port 02},${panel_4_2},${2_2},${room_name_3_2} / ${FACEPLATE_NAME} / ${Port 02},${FACEPLATE_NAME},,
    ...    ${tree_node_room3_report_2},${PANEL_NAME_3},,${LC},${Port 03},${panel_4_2},${3_2},${room_name_3_2} / ${FACEPLATE_NAME} / ${Port 03},${FACEPLATE_NAME},,
    ...    ${tree_node_room3_report_2},${PANEL_NAME_3},,${LC},${Port 04},${panel_4_2},${4_2},${room_name_3_2} / ${FACEPLATE_NAME} / ${Port 04},${FACEPLATE_NAME},,
    ...    ${tree_node_room3_report_2},${PANEL_NAME_3},,${LC},${Port 05},${panel_4_2},${5_2},${room_name_3_2} / ${FACEPLATE_NAME} / ${Port 05},${FACEPLATE_NAME},,
    ...    ${tree_node_room3_report_2},${PANEL_NAME_3},,${LC},${Port 06},${panel_4_2},${6_2},${room_name_3_2} / ${FACEPLATE_NAME} / ${Port 06},${FACEPLATE_NAME},,
    ...    ${tree_node_room4_report_2},${PANEL_NAME_3},,${LC},${Port 01},${panel_4_2},${1_2},${room_name_4_2} / ${FACEPLATE_NAME} / ${Port 01},${FACEPLATE_NAME},,
    ...    ${tree_node_room4_report_2},${PANEL_NAME_3},,${LC},${Port 02},${panel_4_2},${2_2},${room_name_4_2} / ${FACEPLATE_NAME} / ${Port 02},${FACEPLATE_NAME},,
    ...    ${tree_node_room4_report_2},${PANEL_NAME_3},,${LC},${Port 03},${panel_4_2},${3_2},${room_name_4_2} / ${FACEPLATE_NAME} / ${Port 03},${FACEPLATE_NAME},,
    ...    ${tree_node_room4_report_2},${PANEL_NAME_3},,${LC},${Port 04},${panel_4_2},${4_2},${room_name_4_2} / ${FACEPLATE_NAME} / ${Port 04},${FACEPLATE_NAME},,
    ...    ${tree_node_room4_report_2},${PANEL_NAME_3},,${LC},${Port 05},${panel_4_2},${5_2},${room_name_4_2} / ${FACEPLATE_NAME} / ${Port 05},${FACEPLATE_NAME},,
    ...    ${tree_node_room4_report_2},${PANEL_NAME_3},,${LC},${Port 06},${panel_4_2},${6_2},${room_name_4_2} / ${FACEPLATE_NAME} / ${Port 06},${FACEPLATE_NAME},,
    ...    ${tree_node_room5_report_2},${PANEL_NAME_3},,${LC},${Port 01},${panel_4_2},${1_2},${room_name_5_2} / ${FACEPLATE_NAME} / ${Port 01},${FACEPLATE_NAME},,
    ...    ${tree_node_room5_report_2},${PANEL_NAME_3},,${LC},${Port 02},${panel_4_2},${2_2},${room_name_5_2} / ${FACEPLATE_NAME} / ${Port 02},${FACEPLATE_NAME},,
    ...    ${tree_node_room5_report_2},${PANEL_NAME_3},,${LC},${Port 03},${panel_4_2},${3_2},${room_name_5_2} / ${FACEPLATE_NAME} / ${Port 03},${FACEPLATE_NAME},,
    ...    ${tree_node_room5_report_2},${PANEL_NAME_3},,${LC},${Port 04},${panel_4_2},${4_2},${room_name_5_2} / ${FACEPLATE_NAME} / ${Port 04},${FACEPLATE_NAME},,
    ...    ${tree_node_room5_report_2},${PANEL_NAME_3},,${LC},${Port 05},${panel_4_2},${5_2},${room_name_5_2} / ${FACEPLATE_NAME} / ${Port 05},${FACEPLATE_NAME},,
    ...    ${tree_node_room5_report_2},${PANEL_NAME_3},,${LC},${Port 06},${panel_4_2},${6_2},${room_name_5_2} / ${FACEPLATE_NAME} / ${Port 06},${FACEPLATE_NAME},,
    ...    ${tree_node_room6_report_2},${PANEL_NAME_3},,${LC},${Port 01},${panel_4_2},${1_2},${room_name_6_2} / ${FACEPLATE_NAME} / ${Port 01},${FACEPLATE_NAME},${CP_NAME},${room_name_6_2} / ${CP_NAME} / ${Port 01} 
    ...    ${tree_node_room6_report_2},${PANEL_NAME_3},,${LC},${Port 02},${panel_4_2},${2_2},${room_name_6_2} / ${FACEPLATE_NAME} / ${Port 02},${FACEPLATE_NAME},${CP_NAME},${room_name_6_2} / ${CP_NAME} / ${Port 02} 
    ...    ${tree_node_room6_report_2},${PANEL_NAME_3},,${LC},${Port 03},${panel_4_2},${3_2},${room_name_6_2} / ${FACEPLATE_NAME} / ${Port 03},${FACEPLATE_NAME},${CP_NAME},${room_name_6_2} / ${CP_NAME} / ${Port 03} 
    ...    ${tree_node_room6_report_2},${PANEL_NAME_3},,${LC},${Port 04},${panel_4_2},${4_2},${room_name_6_2} / ${FACEPLATE_NAME} / ${Port 04},${FACEPLATE_NAME},${CP_NAME},${room_name_6_2} / ${CP_NAME} / ${Port 04}   
    ...    ${tree_node_room7_report_2},${PANEL_NAME_3},,${LC},${Port 01},${panel_4_2},${1_2},${room_name_7_2} / ${FACEPLATE_NAME} / ${Port 01},${FACEPLATE_NAME},,
    ...    ${tree_node_room7_report_2},${PANEL_NAME_3},,${LC},${Port 02},${panel_4_2},${2_2},${room_name_7_2} / ${FACEPLATE_NAME} / ${Port 02},${FACEPLATE_NAME},,
    ...    ${tree_node_room7_report_2},${PANEL_NAME_3},,${LC},${Port 03},${panel_4_2},${3_2},${room_name_7_2} / ${FACEPLATE_NAME} / ${Port 03},${FACEPLATE_NAME},,
    ...    ${tree_node_room7_report_2},${PANEL_NAME_3},,${LC},${Port 04},${panel_4_2},${4_2},${room_name_7_2} / ${FACEPLATE_NAME} / ${Port 04},${FACEPLATE_NAME},,
    ...    ${tree_node_room8_report_2},${PANEL_NAME_3},,${LC},${Port 01},${panel_4_2},${1_2},${room_name_8_2} / ${FACEPLATE_NAME} / ${Port 01},${FACEPLATE_NAME},,
    ...    ${tree_node_room8_report_2},${PANEL_NAME_3},,${LC},${Port 02},${panel_4_2},${2_2},${room_name_8_2} / ${FACEPLATE_NAME} / ${Port 02},${FACEPLATE_NAME},,
    ...    ${tree_node_room8_report_2},${PANEL_NAME_3},,${LC},${Port 03},${panel_4_2},${3_2},${room_name_8_2} / ${FACEPLATE_NAME} / ${Port 03},${FACEPLATE_NAME},,
    ...    ${tree_node_room8_report_2},${PANEL_NAME_3},,${LC},${Port 04},${panel_4_2},${4_2},${room_name_8_2} / ${FACEPLATE_NAME} / ${Port 04},${FACEPLATE_NAME},,
    ...    ${tree_node_room8_report_2},${PANEL_NAME_3},,${LC},${Port 05},${panel_4_2},${5_2},${room_name_8_2} / ${FACEPLATE_NAME} / ${Port 05},${FACEPLATE_NAME},,
    ...    ${tree_node_room8_report_2},${PANEL_NAME_3},,${LC},${Port 06},${panel_4_2},${6_2},${room_name_8_2} / ${FACEPLATE_NAME} / ${Port 06},${FACEPLATE_NAME},,
       
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29    30    31    32    33    34    35    36    37    38    39    40    41    42    43    44
    
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]