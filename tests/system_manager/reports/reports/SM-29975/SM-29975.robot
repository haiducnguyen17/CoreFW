*** Settings ***
Library   ../../../../../py_sources/logigear/setup.py        
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py       
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/snmp/SNMPPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/reports/reports/ReportsPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/user_defined_fields/AdmPortFieldsPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py  
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/work_order_queue/WorkOrderQueuePage${PLATFORM}.py     

Resource    ../../../../../resources/constants.robot

Default Tags    Reports
Force Tags    SM-29975

Suite Setup    Run Keywords    Open SM Login Page
	...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
	...    AND    Restore Database    ${TC_SM_29975_FILE_NAME}    ${DIR_FILE_BK}
	...    AND    Close Browser

*** Variables ***
${FLOOR_NAME_1}    Floor 01
${FLOOR_NAME_2}    Floor 02
${FLOOR_NAME_3}    Floor 03 
${ROOM_NAME}    Room 01
${RACK_GROUP_NAME}    Rack Group 01
${RACK_NAME}    Rack 001
${SWITCH_NAME_1}    Switch 01
${SWITCH_NAME_2}    Switch 02
${SWITCH_NAME_3}    Blade 1 BX630 F1R5 cabina 1
${SWITCH_NAME_4}    Blade 2 BX630 F1R5 cabina 1
${SERVER_NAME_1}    Server 01
${SERVER_NAME_2}    Server 02
${CARD_NAME_1}    Card 01
${CARD_NAME_2}    Card 02
${FACEPLATE_NAME}    Faceplate 01
${PANEL_NAME_1}    Panel 01
${PANEL_NAME_2}    Panel 02
${PANEL_NAME_3}    Panel 03
${GBIC_SLOT_1}    GBIC Slot 01
${TRAY_NAME}    Tray 01
${BLADE_SERVER_NAME}    Blade Server 01
${ZONE}    1
${POSITION}    1
${TC_SM_29975_30_31_32_FILE_NAME}    SM9.1_TC_SM_29975_30_31_32.bak
${TC_SM_29975_FILE_NAME}    SM-29975-DB.bak
${REPORT_NAME_SM_29975_02_08_09_10_25}    SM-29975-02-08-09-10-25
${REPORT_NAME_SM_29975_03_05_07_19_27_28}    SM-29975-03-05-07-19-27-28
${REPORT_NAME_SM_29975_04_12_23_26}    SM-29975-04-12-23-26
${REPORT_NAME_SM_29975_06_29}    SM-29975-06-29
${REPORT_NAME_SM_29975_15_17}    SM-29975-15-17
${REPORT_NAME_SM_29975_01_20_24}    SM-29975-01-20-24
${WORK_ORDER_1}    00049
${WORK_ORDER_2}    00050
${ENCLOSURE_NAME}    Enclosure 01

*** Test Cases ***
SM-29975-01_Verify That The Circuit Trace Report Is Displayed Correctly With New Customer Circuit (IBM): LC Switch -> patched to -> DM12 -> cabled to -> ${MPO1}2 Panel -> patched New_6xLC to -> LC Server
	[Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
        
    [Teardown]    Close Browser
	        
	${building_name}	Set Variable	Building_SM29975_01
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
        
    # 1. Launch and log into SM Web	
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001: 
	# _LC Switch 01
	# _HSM Panel 01 (DM12)
	# _MPO Panel 02
	# _LC Server 01
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from Panel 01// MPO 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
	# 6. Create the Add Patch job and NOT complete the job with the tasks from: 
	# _Switch 01// 01-06 to Panel 01// 01-06 (WO1)
	# _Panel 02// 01 (${MPO1}2-${MPO1}2)/ 1_1 -> 6_6 New_6xLC to Server 01// 01-06 (WO2)
	# 7. Create Circuit Trace Report with Filter  Scheduled View and observe the data
	# VP: The Data is displayed correctly
    # The Circuit Trace report shows the circuits contain the new New_6xLC assembly correctly
    # Use the new label for pairs of the new New_6xLC assembly
    # Performance has no degradation
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_01_20_24}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    selectFilter=${View}:${Scheduled}    clickViewBtn=${True}    
        
    ${headers}    Set Variable    ${Location},${Service},${Connection (1)},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (2)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (3)},${Room (1)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (4)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}    

	${values_list}    Create List
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${Pair 2}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${Pair 3}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${Pair 4}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${Pair 5}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${Pair 6}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${Pair 2}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${Pair 3}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${Pair 4}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${Pair 5}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${Pair 6}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${Pair 2}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${Pair 3}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${Pair 4}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${Pair 5}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${Pair 6}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${Pair 2}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${Pair 3}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${Pair 4}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${Pair 5}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${Pair 6}
	    
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12
    ...    13    14    15    16    17    18    19    20    21    22    23    24

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# 8. Complete work order	
	Select Main Menu    ${Site Manager}
    Open Work Order Queue Window    
    Complete Work Order    ${WORK_ORDER_1}
    Complete Work Order    ${WORK_ORDER_2}	
    Close Work Order Queue

	# 9. Create Circuit Trace Report with Filter  Currently View
	# VP: The Data is displayed correctly
    # The Circuit Trace report shows the circuits contain the new New_6xLC assembly correctly
    # Use the new label for pairs of the new New_6xLC assembly
    # Performance has no degradation
	    
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_01_20_24}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
           
    ${headers}    Set Variable    ${Location},${Service},${Connection (1)},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (2)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (3)},${Room (1)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (4)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}    

	${values_list}    Create List
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${Pair 2}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${Pair 3}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${Pair 4}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${Pair 5}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${Pair 6}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${Pair 2}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${Pair 3}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${Pair 4}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${Pair 5}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${Pair 6}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${Pair 6}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${Pair 5}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${Pair 4}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${Pair 3}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${Pair 2}    
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${Pair 1}	
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${Pair 2}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${Pair 3}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${Pair 4}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${Pair 5}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${Pair 6}
    
    ${rows_list}    Create List    1    2    3    4    5    6    13    14    15    16    17    18
    ...    61    62    63    64    65    66    90    91    92    93    94    95

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

    # 10. Export csv file and observe
	# Step 10: The data is exported correctly 
	Print Report
    ${site_manager} =    Get Current Tab Alias 
    Open New Tab    ${DOWNLOAD_URL}
    ${csv_file_name} =    Get Print Report File
    Close Current Tab
    Switch Window    ${site_manager}
    ${user_name}=    Get Windows User
    ${download_path}    Set variable    C:\\Users\\${user_name}\\Downloads\\
    Check Data Row In Excel File    ${download_path}${csv_file_name}    8    ${headers} 

    :FOR    ${i}    IN RANGE    0    len(${values_list}) 
    \    Report Bug    SM-30144
    \    ${line}=    Evaluate    ${rows_list}[${i}]+8
    \    Check Data Row In Excel File    ${download_path}${csv_file_name}    ${line}    ${values_list}[${i}] 

(Bulk_SM-29975-02-03-04-05)_Verify That The Circuit Trace Report Is Displayed Correctly
	
	[Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
        
    [Teardown]    Close Browser
	
	# SM-29975-02-Verify that the circuit trace report is displayed correctly with new customer circuit: LC Switch -> patched to -> DM12 -> cabled 6xLC to -> LC -> F2B cabling 6xLC -> DM12 -> patched to -> LC Server
        
	${building_name}	Set Variable	Building_SM29975_02
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    
    # 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001:
	# _LC Switch 01
	# _HSM Panel 01 (DM12)
	# _LC non-iPatch Panel 02
	# _HSM Panel 03 (DM12)
	# _LC Server 01
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from Panel 01// MPO 01 (${MPO1}2-6xLC)/ 1_1 -> 6_6 to Panel 02// 01-06
	# 6. F2B cabling from Panel 02// 01-06 (6xLC-${MPO1}2) to Panel 03// MPO 01/ 1_1 -> 6_6
	# 7. Create the Add Patch job and complete the job with the tasks from:
	# _Switch 01// 01-06 to Panel 01// 01-06
	# _Panel 03// 01-06 to Server 01// 01-06
	# 8. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_02_08_09_10_25}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
       
    ${headers}    Set Variable    ${Location},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Room (3)},${Rack Group (3)},${Rack Position (3)},${Zone ID (3)},${Rack (3)},${Panel (3)},${Panel Port (3)},${Connection (4)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}

	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${01},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${02},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${03},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${04},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${05},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${06},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${01},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${02},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${03},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${04},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${05},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${06},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${01},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${02},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${03},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${04},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${05},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${06},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${01},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${02},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${03},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${04},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${05},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${06},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${01},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${02},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${03},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${04},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${05},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${06},${patched to},${SERVER_NAME_1},,,${06}
	
    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12
    ...    55    56    57    58    59    60    79    80    81    82    83    84    151    152   153    154    155    156

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# SM-29975-03-Verify that the circuit trace report is displayed correctly with new customer circuit: LC Switch -> patched to -> DM12 <- F2B cabling <- ${MPO1}2 Panel -> cabled 6xLC to -> LC Switch
     
    ${building_name}	Set Variable	Building_SM29975_03
	${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    
    # 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001:
	# _LC Switch 01
	# _HSM Panel 01 (DM12)
	# _MPO non-iPatch Panel 02
	# _LC Switch 02
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from Panel 02// 01 (${MPO1}2-6xLC)/ 1_1 -> 6_6 to Switch 02// 01-06
	# 6. F2B cabling from Panel 02// 01 (${MPO1}2-${MPO1}2) to Panel 01// MPO 01
	# 7. Create the Add Patch job and complete the job with the tasks from Switch 01// 01-06 to Panel 01// 01-06
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_03_05_07_19_27_28}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
       
    ${headers}    Set Variable    ${Location},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Equipment (2)},${Equipment Card (2)},${Equipment GBIC Slot (2)},${Equipment Port (2)}
    # ${headers}    Set Variable    Location,Equipment (1),Equipment Card (1),Equipment GBIC Slot (1),Equipment Port (1),Connection (1),Room (1),Rack Group (1),Zone ID (1),Rack Position (1),Rack (1),Panel (1),Panel Port (1),Connection (2),Room (2),Rack Group (2),Zone ID (2),Rack Position (2),Rack (2),Panel (2),Panel Port (2),Connection (3),Equipment (2),Equipment Card (2),Equipment GBIC Slot (2),Equipment Port (2)

	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${03} ${SLASH} ${Pair 3} 
    ...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${patched to},${SWITCH_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${patched to},${SWITCH_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${patched to},${SWITCH_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${patched to},${SWITCH_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${patched to},${SWITCH_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${patched to},${SWITCH_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${patched to},${SWITCH_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${patched to},${SWITCH_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${patched to},${SWITCH_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${patched to},${SWITCH_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${patched to},${SWITCH_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${patched to},${SWITCH_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${patched to},${SWITCH_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${patched to},${SWITCH_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${patched to},${SWITCH_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${patched to},${SWITCH_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${patched to},${SWITCH_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${patched to},${SWITCH_NAME_1},,,${06}
	
    #${headers}    Set Variable    Location,Equipment (1),Equipment Card (1),Equipment GBIC Slot (1),Equipment Port (1),Connection (1),Room (1),Rack Group (1),Zone ID (1),Rack Position (1),Rack (1),Panel (1),Panel Port (1),Connection (2),Room (2),Rack Group (2),Zone ID (2),Rack Position (2),Rack (2),Panel (2),Panel Port (2),Connection (3),Equipment (2),Equipment Card (2),Equipment GBIC Slot (2),Equipment Port (2)

    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12
    ...    55    56    57    58    59    60    104    105    106    107    108    109

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
	# SM-29975-04-Verify that the circuit trace report is displayed correctly with new customer circuit: LC Switch -> patched to -> DM12 -> cabled 6xLC to -> LC Switch
      
	${building_name}	Set Variable	Building_SM29975_04
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    
    # 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001:
	# _LC Switch 01
	# _HSM Panel 01 (DM12)
	# _LC Switch 02
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from Panel 01// MPO 01 (${MPO1}2-6xLC)/ 1_1 -> 6_6 to Switch 02// 01-06
	# 6. Create the Add Patch job and complete the job with the tasks from Switch 01// 01-06 to Panel 01// 01-06 the Add Patch job and complete the job with the tasks from Switch 01// 01-06 to Panel 01// 01-06
    # 7. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_04_12_23_26}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
       
    ${headers}    Set Variable    ${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Location},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)}

	${values_list}    Create List
	...    ${SWITCH_NAME_1},,,${01},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${SWITCH_NAME_2},,,${01}
	...    ${SWITCH_NAME_1},,,${02},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${SWITCH_NAME_2},,,${02}
	...    ${SWITCH_NAME_1},,,${03},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${SWITCH_NAME_2},,,${03}
	...    ${SWITCH_NAME_1},,,${04},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${SWITCH_NAME_2},,,${04}
	...    ${SWITCH_NAME_1},,,${05},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${SWITCH_NAME_2},,,${05}
	...    ${SWITCH_NAME_1},,,${06},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${SWITCH_NAME_2},,,${06}
	...    ${SWITCH_NAME_1},,,${01},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${SWITCH_NAME_2},,,${01}
	...    ${SWITCH_NAME_1},,,${02},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${SWITCH_NAME_2},,,${02}
	...    ${SWITCH_NAME_1},,,${03},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${SWITCH_NAME_2},,,${03}
	...    ${SWITCH_NAME_1},,,${04},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${SWITCH_NAME_2},,,${04}
	...    ${SWITCH_NAME_1},,,${05},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${SWITCH_NAME_2},,,${05}
	...    ${SWITCH_NAME_1},,,${06},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${SWITCH_NAME_2},,,${06}
	...    ${SWITCH_NAME_1},,,${01},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${SWITCH_NAME_2},,,${01}
	...    ${SWITCH_NAME_1},,,${02},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${SWITCH_NAME_2},,,${02}
	...    ${SWITCH_NAME_1},,,${03},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${SWITCH_NAME_2},,,${03}
	...    ${SWITCH_NAME_1},,,${04},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${SWITCH_NAME_2},,,${04}
	...    ${SWITCH_NAME_1},,,${05},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${SWITCH_NAME_2},,,${05}
	...    ${SWITCH_NAME_1},,,${06},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${SWITCH_NAME_2},,,${06}

	${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12
    ...    55    56    57    58    59    60

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	    
	# SM-29975-05-Verify that the circuit trace report is displayed correctly with customer circuit: LC Switch -> patched 6xLC to -> ${MPO1}2 Panel -> cabled to -> ${MPO1}2 Panel -> patched 6xLC to -> LC Server
        
	${building_name}	Set Variable	Building_SM29975_05
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001:
	# _LC Switch 01
	# _MPO Panel 01
	# _MPO Panel 02
	# _LC Server 01
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from Panel 01// 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
	# 6. Create the Add Patch job and complete the job with the tasks from:
	# _Panel 01// 01 (${MPO1}2-6xLC)/ 1_1 -> 6_6 to Switch 01// 01-06
	# _Panel 02// 01 (${MPO1}2-6xLC)/ 1_1 -> 6_6 to Server 01// 01-06
    # 7. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_03_05_07_19_27_28}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
       
    ${headers}    Set Variable    ${Location},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Equipment (2)},${Equipment Card (2)},${Equipment GBIC Slot (2)},${Equipment Port (2)}


	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6} 

	${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12
    ...    36    37    38    39    40    41    65    66    67    68    69    70

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

(Bulk_SM-29975-06-07-08-09-10)_Verify that the circuit trace report is displayed correctly
	[Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
        
    [Teardown]    Close Browser

	# SM-29975-06-Verify that the circuit trace report is displayed correctly with customer circuit: LC Switch -> cabled 6xLC to -> ${MPO1}2 Panel -> F2B cabling to -> ${MPO1}2 Panel -> patched 6xLC to -> LC Server  
    
	${building_name}	Set Variable	Building_SM29975_06
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${SWITCH_NAME_1}
    
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _LC Switch 01 to Room 01
	# _MPO non-iPatch Panel 01 to Rack 001
	# _MPO Panel ${02}, LC Server 01 to Rack 001
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from Panel 01// 01 (${MPO1}2-6xLC)/ 1_1 -> 6_6 to Switch 01// 01-06
	# 6. F2B cabling from Panel 01// 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
	# 7. Create the Add Patch job and complete the job with the tasks from Panel 02// 01 (${MPO1}2-6xLC)/ 1_1 -> 6_6 to Server 01// 01-06
    # 8. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_06_29}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_switch_1}    clickViewBtn=${True} 
       
    ${headers}    Set Variable    ${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Location},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}


	${values_list}    Create List
	...    ${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6} 

	${rows_list}    Create List    1    2    3    4    5    6   

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
    
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_06_29}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Location},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}

	${values_list}    Create List
	...    ${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6} 
	...    ${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6} 
	...    ${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6} 

	${rows_list}    Create List    1    2    3    4    5    6    14    15    16    17    18    19    43    44    45    46    47    48

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# SM-29975-07-Verify that the circuit trace report is displayed correctly with customer circuit: LC Switch -> cabled 6xLC to -> ${MPO1}2 Panel -> patched to -> ${MPO1}2 Panel -> cabled 6xLC to -> LC Switch
       
	${building_name}	Set Variable	Building_SM29975_07
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${SWITCH_NAME_1}
    
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _LC Switch 01 to Room 01
	# _MPO Panel ${01}, MPO Panel ${02}, LC Switch 02 to Rack 001
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from:
	# _Panel 01// 01 (${MPO1}2-6xLC)/ 1_1 -> 6_6 to Switch 01// 01-06
	# _Panel 02// 01 (${MPO1}2-6xLC)/ 1_1 -> 6_6 to Switch 02// 01-06
	# 6. Create the Add Patch job and complete the job with the tasks from Panel 01// 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
    # 7. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_03_05_07_19_27_28}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_switch_1}    clickViewBtn=${True} 
       
    ${headers}    Set Variable    ${Location},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Equipment (2)},${Equipment Card (2)},${Equipment GBIC Slot (2)},${Equipment Port (2)}


	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${06} ${SLASH} ${Pair 6} 

	${rows_list}    Create List    1    2    3    4    5    6   

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
    
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_03_05_07_19_27_28}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Equipment (2)},${Equipment Card (2)},${Equipment GBIC Slot (2)},${Equipment Port (2)}


	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6} 

	${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12    36    37    38    39    40    41

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# SM-29975-08-Verify that the circuit trace report is displayed correctly with customer circuit: LC Switch -> patched 6xLC to -> ${MPO1}2 Panel -> cabled to -> ${MPO1}2 Panel -> F2B cabling -> LC Panel -> patched to -> LC Server
        
	${building_name}	Set Variable	Building_SM29975_08
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001:
	# _LC Switch 01
	# _MPO Panel 01
	# _MPO non-iPatch Panel 02
	# _LC Panel 03 (LC 12 Port - Pass-Through)
	# _LC Server 01
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from Panel 01// 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
	# 6. F2B cabling from Panel 02// 01 (${MPO1}2-6xLC)/ 1_1 -> 6_6 to Panel 03// 01-06
	# 7. Create the Add Patch job and complete the job with the tasks from:
	# _Panel 01// 01 (${MPO1}2-6xLC)/ 1_1 -> 6_6 to Switch 01// 01-06
	# _Panel 03// 01-06 to Server 01// 01-06
    # 8. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_02_08_09_10_25}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Room (3)},${Rack Group (3)},${Rack Position (3)},${Zone ID (3)},${Rack (3)},${Panel (3)},${Panel Port (3)},${Connection (4)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}


	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${02} ${SLASH} ${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${03} ${SLASH} ${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${04} ${SLASH} ${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${05} ${SLASH} ${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${06} ${SLASH} ${Pair 6},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${02} ${SLASH} ${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${03} ${SLASH} ${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${04} ${SLASH} ${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${05} ${SLASH} ${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${06} ${SLASH} ${Pair 6},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${02} ${SLASH} ${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${03} ${SLASH} ${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${04} ${SLASH} ${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${05} ${SLASH} ${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${06} ${SLASH} ${Pair 6},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${02} ${SLASH} ${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${03} ${SLASH} ${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${04} ${SLASH} ${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${05} ${SLASH} ${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${06} ${SLASH} ${Pair 6},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${02} ${SLASH} ${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${03} ${SLASH} ${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${04} ${SLASH} ${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${05} ${SLASH} ${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${Pass-Through}),${06} ${SLASH} ${Pair 6},${patched to},${SERVER_NAME_1},,,${06}

	${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12    36    37    38    39    40    41
	...    85    86    87    88    89    90    187    188    189    190    191    192

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# SM-29975-09-Verify that the circuit trace report is displayed correctly with customer circuit: LC Switch -> cabled 6xLC to -> ${MPO1}2 Panel -> patched to -> ${MPO1}2 Panel -> cabled 6x LC to -> LC Panel -> patched to -> LC Server
        
	${building_name}	Set Variable	Building_SM29975_09
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${SWITCH_NAME_1}
    
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _LC Switch 01 to Room 01
	# _MPO Panel ${01}, MPO Panel ${02}, LC Panel ${03}, LC Server 01 to Rack 001
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from:
	# _Panel 01// 01 (${MPO1}2-6xLC)/ 1_1 -> 6_6 to Switch 01// 01-06
	# _Panel 02// 01 (${MPO1}2-6xLC) ${SLASH} ${1-1} -> 6_6  to Panel 03// MPO 01-06
	# 6. Create the Add Patch job and DO NOT complete the job with the tasks from:
	# _Panel 01// 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
	# _Panel 03// 01-06 to Server 01// 01-06
    # 7. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_02_08_09_10_25}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_switch_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Room (3)},${Rack Group (3)},${Rack Position (3)},${Zone ID (3)},${Rack (3)},${Panel (3)},${Panel Port (3)},${Connection (4)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}

	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${SLASH}${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${02} ${SLASH} ${SLASH}${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${03} ${SLASH} ${SLASH}${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${04} ${SLASH} ${SLASH}${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${05} ${SLASH} ${SLASH}${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${06} ${SLASH} ${SLASH}${Pair 6},${patched to},${SERVER_NAME_1},,,${06}

	${rows_list}    Create List    1    2    3    4    5    6

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_02_08_09_10_25}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Room (3)},${Rack Group (3)},${Rack Position (3)},${Zone ID (3)},${Rack (3)},${Panel (3)},${Panel Port (3)},${Connection (4)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}

	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${SLASH}${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${02} ${SLASH} ${SLASH}${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${03} ${SLASH} ${SLASH}${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${04} ${SLASH} ${SLASH}${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${05} ${SLASH} ${SLASH}${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${06} ${SLASH} ${SLASH}${Pair 6},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${SLASH}${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${02} ${SLASH} ${SLASH}${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${03} ${SLASH} ${SLASH}${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${04} ${SLASH} ${SLASH}${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${05} ${SLASH} ${SLASH}${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${06} ${SLASH} ${SLASH}${Pair 6},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${SLASH}${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${02} ${SLASH} ${SLASH}${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${03} ${SLASH} ${SLASH}${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${04} ${SLASH} ${SLASH}${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${05} ${SLASH} ${SLASH}${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${06} ${SLASH} ${SLASH}${Pair 6},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${SLASH}${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${02} ${SLASH} ${SLASH}${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${03} ${SLASH} ${SLASH}${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${04} ${SLASH} ${SLASH}${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${05} ${SLASH} ${SLASH}${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${06} ${SLASH} ${SLASH}${Pair 6},${patched to},${SERVER_NAME_1},,,${06}

	${rows_list}    Create List    1    2    3    4    5    6    30    31    32    33    34    35
	...    59    60    61    62    63    64    83    84    85    86    87    88

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# SM-29975-10-Verify that the circuit trace report is displayed correctly with customer circuit: LC Switch -> patched to -> MPO 12 Panel -> cabled to -> ${MPO1}2 Panel -> F2B 6xLC cabling -> LC Panel -> patched to -> LC Server
    
	${building_name}	Set Variable	Building_SM29975_10
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${SWITCH_NAME_1}
    
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001:
	# _LC Switch 01
	# _MPO non-iPatch Panel 01
	# _MPO non-iPatch Panel 02
	# _LC Panel 03
	# _LC Server 01
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from Panel 01// MPO 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
	# 6. F2B cabling from Panel 02// 01 (${MPO1}2-6xLC)/ 1_1 -> 6_6 to Panel 03// 01-06
	# 7. Create the Add Patch job and complete the job with the tasks from:
	# _Panel 01//01 to Switch 01// 01-06
	# _Panel 03// 01-06 to Server 01// 01-06
    # 8. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_02_08_09_10_25}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Room (3)},${Rack Group (3)},${Rack Position (3)},${Zone ID (3)},${Rack (3)},${Panel (3)},${Panel Port (3)},${Connection (4)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}

	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${02} ${SLASH} ${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${03} ${SLASH} ${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${04} ${SLASH} ${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${05} ${SLASH} ${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${06} ${SLASH} ${Pair 6},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${02} ${SLASH} ${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${03} ${SLASH} ${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${04} ${SLASH} ${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${05} ${SLASH} ${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${06} ${SLASH} ${Pair 6},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${02} ${SLASH} ${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${03} ${SLASH} ${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${04} ${SLASH} ${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${05} ${SLASH} ${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${06} ${SLASH} ${Pair 6},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${02} ${SLASH} ${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${03} ${SLASH} ${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${04} ${SLASH} ${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${05} ${SLASH} ${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${06} ${SLASH} ${Pair 6},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${Pair 1},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${02} ${SLASH} ${Pair 2},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${03} ${SLASH} ${Pair 3},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${04} ${SLASH} ${Pair 4},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${05} ${SLASH} ${Pair 5},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${06} ${SLASH} ${Pair 6},${patched to},${SERVER_NAME_1},,,${06}

	${rows_list}    Create List    1    2    3    4    5    6    14    15    16    17    18    19
	...    39    40    41    42    43    44    64    65    66    67    68    69    88    89    90    91    92    93

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

(Bulk_SM-29975-11-12-13-15)_Verify that the circuit trace report is displayed correctly 
	[Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
        
    [Teardown]    Close Browser
	
	# SM-29975-11-Verify that the circuit trace report is displayed correctly with circuit: LC Switch -> cabled 6xLC to -> ${MPO1}2 Panel -> patched 6xLC to -> LC Panel -> cabled to -> LC Faceplate
     
	${building_name}	Set Variable	Building_SM29975_11
	${report_name_sm_29975_11}	Set Variable	SM-29975-11	
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${SWITCH_NAME_1}
    ${tree_node_faceplate_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${FACEPLATE_NAME}
   
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _LC Switch ${01}, LC Faceplate 01 to Room 01
	# _MPO Panel ${01}, LC Panel 02 to Rack 001
	# 4. Set Data service for Switch 01// 01 directly
	# 5. Cable from:
	# _Panel 01// 01 (${MPO1}2-6xLC)/ 1_1 to Switch 01// 01
	# _Panel 02// 01 to Faceplate 01// 01
	# 6. Create the Add Patch job and complete the job with the task from Panel 01// 01 (${MPO1}2-6xLC)/ 1_1 to Panel 02// 01
    # 7. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${report_name_sm_29975_11}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_switch_1};${tree_node_faceplate_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Faceplate},${Outlet}

	${values_list}    Create List
    ...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 1},${cabled to},${FACEPLATE_NAME},${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 1},${cabled to},${FACEPLATE_NAME},${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,,,,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,,,,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,,,,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,,,,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,,,,,,,

	${rows_list}    Create List    1	7    8    9    10    11    12
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
    
    Select Main Menu    ${Reports}
    View Report    ${report_name_sm_29975_11}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Faceplate},${Outlet}

	${values_list}    Create List
    ...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,,,,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,,,,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,,,,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,,,,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,,,,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 1},${cabled to},${FACEPLATE_NAME},${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 1},${cabled to},${FACEPLATE_NAME},${01}

	${rows_list}    Create List    1	2    3    4    5    6    30
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# SM-29975-12-Verify that the circuit trace report is displayed correctly with circuit: LC Switch -> cabled 6xLC to -> ${MPO1}2 Panel -> patched 6xLC to -> LC Server
        
	${building_name}	Set Variable	Building_SM29975_12
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
   
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001:
	# _LC Switch 01
	# _MPO Panel 01
	# _LC Server 01
	# 4. Set Data service for Switch 01// 01 directly
	# 5. Cable from Panel 01// 01 (${MPO1}2-6xLC)/ 1_1 to Switch 01// 01
	# 6. Create the Add Patch job and complete the job with the task from Panel 01// 01 (${MPO1}2-6xLC)/ 1_1 to Server 01// 01	# 6. Create the Add Patch job and complete the job with the task from Panel 01// 01 (${MPO1}2-6xLC)/ 1_1 to Panel 02// 01
    # 7. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_04_12_23_26}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Location},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)}


	${values_list}    Create List
    ...    ${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
    ...    ${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
    ...    ${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}

	${rows_list}    Create List    1	14    38
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
	# SM-29975-13-Verify that the circuit trace report is displayed correctly with circuit: LC Switch -> patched to -> LC Panel -> cabled to -> Splice - Splice -> cabled to -> LC Panel -> patched 6xLC to -> MPO Panel
       
	${building_name}	Set Variable	Building_SM29975_13
	${report_name_sm_29975_13}    Set Variable	SM-29975-13
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tree_node_enclosure_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ENCLOSURE_NAME}
   
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _LC Splice Enclosure 01/ Tray 01 to Room 01
	# _LC Switch ${01}, LC Panel ${01}, LC Panel ${02}, MPO Panel 03 to Rack 001
	# 4. Set Data service for Switch 01// 01 directly
	# 5. Cable from:
	# _Panel 01// 01 to Splice Enclosure 01// 01 In & 02 In
	# _Panel 02// 01 to Splice Enclosure 01// 01 Out & 02 Out
	# 6. Create the Add Patch job and complete the job with the tasks from:
	# _Switch 01// 01 to Panel 01// 01
	# _Panel 03// 01 (${MPO1}2-6xLC EB)/ 1_1 to Panel 02// 01
	# 7. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${report_name_sm_29975_13}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1};${tree_node_enclosure_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Splice Enclosure (1)},${Splice Tray (1)},${Splice (1)},${Connection (3)},${Splice Enclosure (2)},${Splice Tray (2)},${Splice (2)},${Connection (4)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (5)},${Room (3)},${Rack Group (3)},${Rack Position (3)},${Zone ID (3)},${Rack (3)},${Panel (3)},${Panel Port (3)}

	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${B},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${A},${cabled to},${ENCLOSURE_NAME},${TRAY_NAME},${01} ${In},${connected to},${ENCLOSURE_NAME},${TRAY_NAME},${01} ${Out},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${A},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${B},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${A},${cabled to},${ENCLOSURE_NAME},${TRAY_NAME},${01} ${In},${connected to},${ENCLOSURE_NAME},${TRAY_NAME},${01} ${Out},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${A},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${A},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${B},${cabled to},${ENCLOSURE_NAME},${TRAY_NAME},${02} ${In},${connected to},${ENCLOSURE_NAME},${TRAY_NAME},${02} ${Out},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${B},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${A},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${B},${cabled to},${ENCLOSURE_NAME},${TRAY_NAME},${02} ${In},${connected to},${ENCLOSURE_NAME},${TRAY_NAME},${02} ${Out},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${B},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${A},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${B},${cabled to},${ENCLOSURE_NAME},${TRAY_NAME},${02} ${In},${connected to},${ENCLOSURE_NAME},${TRAY_NAME},${02} ${Out},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${B},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${B},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${A},${cabled to},${ENCLOSURE_NAME},${TRAY_NAME},${01} ${In},${connected to},${ENCLOSURE_NAME},${TRAY_NAME},${01} ${Out},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${A},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${B},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${A},${cabled to},${ENCLOSURE_NAME},${TRAY_NAME},${01} ${In},${connected to},${ENCLOSURE_NAME},${TRAY_NAME},${01} ${Out},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${A},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${A},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${B},${cabled to},${ENCLOSURE_NAME},${TRAY_NAME},${02} ${In},${connected to},${ENCLOSURE_NAME},${TRAY_NAME},${02} ${Out},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${B},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${B},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${A},${cabled to},${ENCLOSURE_NAME},${TRAY_NAME},${01} ${In},${connected to},${ENCLOSURE_NAME},${TRAY_NAME},${01} ${Out},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${A},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${A},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${B},${cabled to},${ENCLOSURE_NAME},${TRAY_NAME},${02} ${In},${connected to},${ENCLOSURE_NAME},${TRAY_NAME},${02} ${Out},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${B},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01},${cabled to},${ENCLOSURE_NAME},${TRAY_NAME},${01} ${In},${connected to},${ENCLOSURE_NAME},${TRAY_NAME},${01} ${Out},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1}

	${rows_list}    Create List    1    2    3    4    49    50    63    64    88    89    113
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# SM-29975-15-Verify that the circuit trace report is displayed correctly with circuit: ${MPO1}2 Panel -> patched New_6xLC to -> LC Panel
       
	${building_name}	Set Variable	Building_SM29975_15
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
   
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001:
	# _MPO Panel 01
	# _LC Panel 02
	# 4. Set Data service for Panel 01// 01 directly
	# 5. Create the Add Patch job and complete the job with the task from Panel 01// 01 (${MPO1}2-New_6xLC)/ 1_1 -> 2_2 to Panel 02// 01-02
	# 6. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_15_17}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Service},${Connection (1)},${Room (1)},${Rack Group (1)},${Rack Position (1)},${Zone ID (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Rack Position (2)},${Zone ID (2)},${Rack (2)},${Panel (2)},${Panel Port (2)}

	${values_list}    Create List
    ...    ${tree_node_room_1},${Data},${service provided to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${Data},${service provided to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${02} ${SLASH} ${Pair 2} 

	${rows_list}    Create List    1    2    26    27
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

(Bulk_SM-29975-16-17-18)_Verify that the circuit trace report is displayed correctly
	[Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
        
    [Teardown]    Close Browser
    
    [Tags]    Sanity

	# SM-29975-16-Verify that the circuit trace report is displayed correctly with circuit: ${MPO1}2 Panel -> patched New_6xLC to -> LC Switch
     
	${building_name}	Set Variable	Building_SM29975_16
	${report_name_sm_29975_16}    Set Variable	SM-29975-16
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
   
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001:
	# _MPO Panel 01
	# _LC Switch 01
	# 4. Set Data service for Switch 01// 01 directly
	# 5. Create the Add Patch job and complete the job with the task from Panel 01// 01 (${MPO1}2-New_6xLC)/ 1_1 to Switch 01// 01
	# 6. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${report_name_sm_29975_16}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Service},${Connection (1)},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (2)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)}

	${values_list}    Create List
    ...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1}

	${rows_list}    Create List    1    14
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
	# SM-29975-17-Verify that the circuit trace report is displayed correctly with circuit: ${MPO1}2 Panel -> F2B cabling
    
	${building_name}	Set Variable	Building_SM29975_17
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
   
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001:
	# _MPO Panel 01
	# _LC Switch 01
	# 4. Set Data service for Switch 01// 01 directly
	# 5. Create the Add Patch job and complete the job with the task from Panel 01// 01 (${MPO1}2-New_6xLC)/ 1_1 to Switch 01// 01
	# 6. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_15_17}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Service},${Connection (1)},${Room (1)},${Rack Group (1)},${Rack Position (1)},${Zone ID (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Rack Position (2)},${Zone ID (2)},${Rack (2)},${Panel (2)},${Panel Port (2)}

	${values_list}    Create List
    ...    ${tree_node_room_1},${Data},${service provided to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 3}
	...    ${tree_node_room_1},${Data},${service provided to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 3}

	${rows_list}    Create List    1    25
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
	# SM-29975-18-Verify that user can create cabling MPO12-New_6xLC from HSM Port (DM08) to LC Panel Port
    
	${building_name}	Set Variable	Building_SM29975_18
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} / ${building_name} / ${FLOOR_NAME_1} / ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${REPORT_NAME_SM_29975_18}    Set Variable    SM-29975-18

	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _HSM Panel 01 (DM08)
	# _LC Panel 02
	# 4. Cable from Panel 01// MPO 01 (MPO12-New_6xLC)/ 1-1 -> 6-6 to Panel 02// 01-06
	# 5. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_18}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
       
    ${headers}    Set Variable    ${Location},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (1)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)}

	${values_list}    Create List
	...    ${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${03},${CABLED_TO},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${03}
	...    ${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${04},${CABLED_TO},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${04}
	...    ${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${01},${CABLED_TO},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01}
	...    ${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${02},${CABLED_TO},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${02}
	...    ${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},${CABLED_TO},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${01}
	...    ${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${02},${CABLED_TO},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${02}
	...    ${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${03},${CABLED_TO},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${03}
	...    ${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${04},${CABLED_TO},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${04}
	...    ${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${05},${CABLED_TO},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${No Path}
	...    ${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${06},${CABLED_TO},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${No Path}
	
    ${rows_list}    Create List    1    2    7    8    55    56    57    58    59    60

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

SM-29975-19_Verify that the Trace window displays correctly for circuit: LC Switch -> DM08 -> ${MPO1}2 Panel -> LC Server
	[Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
        
    [Teardown]    Close Browser
        
	${building_name}	Set Variable	Building_SM29975_19
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}

	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _HSM Panel 01 (DM08)
	# _LC Panel 02
	# 4. Cable from Panel 01// MPO 01 (${MPO1}2-New_6xLC)/ 1_1 -> 6_6 to Panel 02// 01-06
	# 5. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_03_05_07_19_27_28}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
       
    ${headers}    Set Variable    ${Location},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Equipment (2)},${Equipment Card (2)},${Equipment GBIC Slot (2)},${Equipment Port (2)}

	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${01},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${MPO1}-${02},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${MPO1}-${03},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${MPO1}-${04},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${MPO1}-${03},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${MPO1}-${04},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${01},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${MPO1}-${02},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${01},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${MPO1}-${02},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${MPO1}-${03},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${MPO1}-${04},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${No Path},,,,,
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${No Path},,,,,
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${01},${patched to},${SWITCH_NAME_1},,,${01}
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${MPO1}-${02},${patched to},${SWITCH_NAME_1},,,${02}
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${MPO1}-${03},${patched to},${SWITCH_NAME_1},,,${03}
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${MPO1}-${04},${patched to},${SWITCH_NAME_1},,,${04}
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${No Path},,,,,
	...    ${tree_node_room_1},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM08}),${${MPO1}}-${No Path},,,,,
	
    ${rows_list}    Create List    1    2    3    4    7    8    13    14    37    38    39    40    41    42
    ...    66    67    68    69    70    71
    
    Report Bug    SM-30061
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

(Bulk_SM-29975-20-21-22-23-24)_Verify that the circuit trace report is displayed correctly
	[Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
        
    [Teardown]    Close Browser

	# SM-29975-20-Verify that the circuit trace report is displayed correctly with real device in new customer circuit (IBM): LC Switch -> patched to -> DM12 -> cabled to -> ${MPO1}2 Panel -> patched New_6xLC to -> LC Server
       
	${building_name}	Set Variable	Building_SM29975_20
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
	# 1. Prepare a NM with HSM Panel 01 (DM12) and MPO Panel 02
	# 2. Launch and log into SM Web
	# 3. Go to "Site Manager" page
	# 4. Add to Rack 001: 
	# _LC Switch 01
	# _NM above and sync it successfully
	# _LC Server 01
	# 5. Set Data service for Switch 01// 01-06 directly
	# 6. Cable from Panel 01// MPO 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
	# 7. Create the "Immediate" Add Patch job and complete the job with the tasks from: 
	# _Switch 01// 01-06 to Panel 01// 01-06
	# _Panel 02// 01 (${MPO1}2-New_6xLC EB)/ 1_1 -> 6_6 to Server 01// 01-06 
	# 8. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_01_20_24}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Service},${Connection (1)},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (2)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (3)},${Room (1)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (4)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}


	${values_list}    Create List
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${01},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${02},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${03},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${04},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${05},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${06},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${06},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${05},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${04},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${03},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${02},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${01},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${01},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${02},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${03},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${04},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${05},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${06},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${01},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${02},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${03},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${04},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${05},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_4},,,${06},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},,,${06} ${SLASH} ${Pair 6} 

	${rows_list}    Create List    1    2    3    4    5    6    145    146    147    148    149    150    174    175    176    177    178    179
	...    187    188    189    190    191    192
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# SM-29975-21-Verify that the circuit trace report is displayed correctly with real device in new customer circuit: LC Switch -> patched to -> DM12 -> cabled New_6xLC to -> LC -> F2B cabling New_6xLC -> DM12 -> patched to -> LC Server
       
	${building_name}	Set Variable	Building_SM29975_21
	${report_name_sm_29975_21}    Set Variable    SM-29975-21
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
	
	# 1. Prepare a NM with HSM Panel 01 (DM12) and HSM Panel 03 (DM12)
	# 2. Launch and log into SM Web
	# 3. Go to "Site Manager" page
	# 4. Add to Rack 001: 
	# _LC Switch 01
	# _LC non-iPatch Panel 02
	# _NM above and sync it successfully
	# _LC Server 01
	# 5. Set Data service for Switch 01// 01-06 directly
	# 6. Cable from Panel 01// MPO 01 (${MPO1}2-New_6xLC)/ 1_1 -> 6_6 to Panel 02// 01-06
	# 7. F2B cabling from Panel 02// 01-06 (New_6xLC-${MPO1}2) to Panel 03// MPO 01/ 1_1 -> 6_6
	# 8. Create the "Immediate" Add Patch job and complete the job with the tasks from: 
	# _Switch 01// 01-06 to Panel 01// 01-06
	# _Panel 03// 01-06 to Server 01// 01-06 
	# 9. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${report_name_sm_29975_21}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Service},${Connection (1)},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)},${Connection (2)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (3)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (4)},${Room (3)},${Rack Group (3)},${Rack Position (3)},${Zone ID (3)},${Rack (3)},${Panel (3)},${Panel Port (3)},${Connection (5)},${Equipment (2)},${Equipment Card (2)},${Equipment GBIC Slot (2)},${Equipment Port (2)}

	${values_list}    Create List
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${01},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${02},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${03},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${04},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${05},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${06},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${01},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${02},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${03},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${04},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${05},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${06},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${01},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${02},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${03},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${04},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${05},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${06},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${01},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${02},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${03},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${04},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${05},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${06},${patched to},${SERVER_NAME_1},,,${06}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${01},${patched to},${SERVER_NAME_1},,,${01}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${02},${patched to},${SERVER_NAME_1},,,${02}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${03},${patched to},${SERVER_NAME_1},,,${03}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${04},${patched to},${SERVER_NAME_1},,,${04}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${05},${patched to},${SERVER_NAME_1},,,${05}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3} ${SLASH} ${Module 1A} (${DM12}),${06},${patched to},${SERVER_NAME_1},,,${06}

	${rows_list}    Create List    1    2    3    4    5    6    73    74    75    76    77    78
	...    217    218    219    220    221    222    313    314    315    316    317    318    326    327    328    329    330    331
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# SM-29975-22-Verify that the circuit trace report is displayed correctly with real device in new customer circuit: LC Switch -> patched to -> DM12 <- F2B cabling <- ${MPO1}2 Panel -> cabled New_6xLC to -> LC Switch
    
	${building_name}	Set Variable	Building_SM29975_22
	${report_name_sm_29975_22}    Set Variable    SM-29975-22
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
	
	# 1. Prepare a NM with HSM Panel 01 (DM12)
	# 2. Launch and log into SM Web
	# 3. Go to "Site Manager" page
	# 4. Add to Rack 001: 
	# _LC Switch 01
	# _NM above and sync it successfully
	# _MPO non-iPatch Panel 02
	# _LC Switch 02
	# 5. Set Data service for Switch 01// 01-06 directly
	# 6. Cable from Panel 02// 01 (${MPO1}2-New_6xLC)/ 1_1 -> 6_6 to Switch 02// 01-06
	# 7. F2B cabling from Panel 02// 01 (${MPO1}2-${MPO1}2) to Panel 01// MPO 01
	# 8. Create the "Immediate" Add Patch job and complete the job with the tasks from Switch 01// 01-06 to Panel 01// 01-06	# _Panel 03// 01-06 to Server 01// 01-06 
	# 9. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${report_name_sm_29975_22}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Service},${Connection (1)},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (2)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},Connection (3),Room (2),Rack Group (2),Zone ID (2),Rack Position (2),Rack (2),Panel (2),Panel Port (2),Connection (4),Equipment (1),Equipment Card (1),Equipment GBIC Slot (1),Equipment Port (1)

	${values_list}    Create List
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${01},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${02},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${03},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${04},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${05},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,,${06},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,,${06} ${SLASH} ${Pair 6} 

	${rows_list}    Create List    1    2    3    4    5    6    73    74    75    76    77    78
	...    170    171    172    173    174    175    176    177    178    179    180    181
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# SM-29975-23-Verify that the circuit trace report is displayed correctly with real device in new customer circuit: LC Switch -> patched to -> DM12 -> cabled New_6xLC to -> LC Switch
      
	${building_name}	Set Variable	Building_SM29975_23
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
	
	# 1. Prepare a NM with HSM Panel 01 (DM12)
	# 2. Launch and log into SM Web
	# 3. Go to "Site Manager" page
	# 4. Add to Rack 001: 
	# _LC Switch 01
	# _NM above and sync it successfully
	# _LC Switch 02
	# 5. Set Data service for Switch 01// 01-06 directly
	# 6. Cable from Panel 01// MPO 01 (${MPO1}2-New_6xLC)/ 1_1 -> 6_6 to Switch 02// 01-06
	# 7. Create the "Immediate" Add Patch job and complete the job with the tasks from Switch 01// 01-06 to Panel 01// 01-06
	# 8. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_04_12_23_26}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Location},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)}

	${values_list}    Create List
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${01},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${SWITCH_NAME_4},,,${01}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${02},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${SWITCH_NAME_4},,,${02}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${03},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${SWITCH_NAME_4},,,${03}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${04},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${SWITCH_NAME_4},,,${04}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${05},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${SWITCH_NAME_4},,,${05}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${06},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${SWITCH_NAME_4},,,${06}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${01},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${SWITCH_NAME_4},,,${01}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${02},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${SWITCH_NAME_4},,,${02}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${03},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${SWITCH_NAME_4},,,${03}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${04},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${SWITCH_NAME_4},,,${04}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${05},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${SWITCH_NAME_4},,,${05}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${06},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${SWITCH_NAME_4},,,${06}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${01},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${01},${cabled to},${SWITCH_NAME_4},,,${01}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${02},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${02},${cabled to},${SWITCH_NAME_4},,,${02}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${03},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${03},${cabled to},${SWITCH_NAME_4},,,${03}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${04},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${04},${cabled to},${SWITCH_NAME_4},,,${04}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${05},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${05},${cabled to},${SWITCH_NAME_4},,,${05}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${06},${patched to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${DM12}),${06},${cabled to},${SWITCH_NAME_4},,,${06}

	${rows_list}    Create List    1    2    3    4    5    6    25    26    27    28    29    30    38    39    40    41    42    43
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
	# SM-29975-24-Verify that the circuit trace report is displayed correctly with real device in customer circuit: LC Switch -> patched New_6xLC to -> ${MPO1}2 Panel -> cabled to -> ${MPO1}2 Panel -> patched New_6xLC to -> LC Server
        
	${building_name}	Set Variable	Building_SM29975_24
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
	
	# 1. Prepare a NM with MPO Panel 01 and MPO Panel 02
	# 2. Launch and log into SM Web
	# 3. Go to "Site Manager" page
	# 4. Add to Rack 001: 
	# _LC Switch 01
	# _NM above and sync it successfully
	# _LC Server 01
	# 5. Set Data service for Switch 01// 01-06 directly
	# 6. Cable from Panel 01// 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
	# 7. Create the "Immediate" Add Patch job and complete the job with the tasks from: 
	# _Panel 01// 01 (${MPO1}2-New_6xLC)/ 1_1 -> 6_6 to Switch 01// 01-06
	# _Panel 02// 01 (${MPO1}2-New_6xLC)/ 1_1 -> 6_6 to Server 01// 01-06
	# 8. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_01_20_24}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Service},${Connection (1)},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (2)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (3)},${Room (1)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (4)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}

	${values_list}    Create List
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06} ${SLASH} ${Pair 6},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05} ${SLASH} ${Pair 5},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04} ${SLASH} ${Pair 4},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03} ${SLASH} ${Pair 3},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02} ${SLASH} ${Pair 2},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01} ${SLASH} ${Pair 1},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06} ${SLASH} ${Pair 6},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05} ${SLASH} ${Pair 5},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04} ${SLASH} ${Pair 4},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03} ${SLASH} ${Pair 3},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02} ${SLASH} ${Pair 2},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01} ${SLASH} ${Pair 1},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01} ${SLASH} ${Pair 1},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02} ${SLASH} ${Pair 2},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03} ${SLASH} ${Pair 3},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04} ${SLASH} ${Pair 4},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05} ${SLASH} ${Pair 5},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06} ${SLASH} ${Pair 6},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${06} ${SLASH} ${Pair 6} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01} ${SLASH} ${Pair 1},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02} ${SLASH} ${Pair 2},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03} ${SLASH} ${Pair 3},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04} ${SLASH} ${Pair 4},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05} ${SLASH} ${Pair 5},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${05} ${SLASH} ${Pair 5} 
	...    ${tree_node_room_1},${Data},${service provided to},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06} ${SLASH} ${Pair 6},${patched to},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,,${06} ${SLASH} ${Pair 6} 

	${rows_list}    Create List    1    2    3    4    5    6    22    23    24    25    26    27
	...    43    44    45    46    47    48    49    50    51    52    53    54
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

(Bulk_SM-29975-25-26-27-28-29)_Verify that the circuit trace report is displayed correctly	
	[Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
        
    [Teardown]    Close Browser

	# SM-29975-25-Verify that the circuit trace report is displayed correctly with circuit: ${MPO1}2 Panel -> F2B cabling
        
	${building_name}	Set Variable	Building_SM29975_25
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001:
	# _MPO24 Switch 01
	# _MPO Panel 01
	# _LC Panel 02
	# _MPO Panel 03
	# _MPO24 Server 01
	# 4. Set Data service for Switch 01// 01 directly
	# 5. Cable from Switch 01// 01 (MPO24-3xMPO)/ B1 to Panel 01// 01
	# 6. F2B cabling from:
	# _Panel 01// 01 (${MPO1}2-New_6xLC EB)/ ${Pair 1} -> Pair 6 to Panel 02// 01-06
	# _Panel 02// 01-06 (New_6xLC EB-${MPO1}2) to Panel 03// 01/ ${Pair 1} -> Pair 6
	# 7. Create the Add Patch job and complete the job from Switch 02// 01 (MPO24-3xMPO)/ B1 to Panel 03// 01
	# 8. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_02_08_09_10_25}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Room (3)},${Rack Group (3)},${Rack Position (3)},${Zone ID (3)},${Rack (3)},${Panel (3)},${Panel Port (3)},${Connection (4)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}


	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${02} ${SLASH} ${Pair 2},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${03} ${SLASH} ${Pair 3},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${04} ${SLASH} ${Pair 4},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${05} ${SLASH} ${Pair 5},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${06} ${SLASH} ${Pair 6},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${02} ${SLASH} ${Pair 2},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${03} ${SLASH} ${Pair 3},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${04} ${SLASH} ${Pair 4},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${05} ${SLASH} ${Pair 5},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${06} ${SLASH} ${Pair 6},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${02} ${SLASH} ${Pair 2},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${03} ${SLASH} ${Pair 3},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${04} ${SLASH} ${Pair 4},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${05} ${SLASH} ${Pair 5},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${06} ${SLASH} ${Pair 6},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${02} ${SLASH} ${Pair 2},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${03} ${SLASH} ${Pair 3},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${04} ${SLASH} ${Pair 4},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${05} ${SLASH} ${Pair 5},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${06} ${SLASH} ${Pair 6},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${Pair 1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${02} ${SLASH} ${Pair 2},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${03} ${SLASH} ${Pair 3},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${04} ${SLASH} ${Pair 4},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${05} ${SLASH} ${Pair 5},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${06} ${SLASH} ${Pair 6},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_3},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${A1}

	${rows_list}    Create List    1    2    3    4    5    6    30    31    32    33    34    35
	...    41    42    43    44    45    46    47    48    49    50    51    52    58    59    60    61    62    63
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
	# SM-29975-26-Verify that the customer circuit is displayed correctly: LC Switch -> cabled New_6xLC to -> ${MPO1}2 Panel -> patched 4xLC to -> LC Server
        
	${building_name}	Set Variable	Building_SM29975_26
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
	
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001:
	# _LC Switch 01
	# _MPO Panel 01
	# _LC Server 01
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from Panel 01// 01 (${MPO1}2-New_6xLC EB)/ ${Pair 1} -> Pair 6 to Switch 01// 01-06
	# 6. Create the Add Patch job and complete the job from Panel 01// 01 (${MPO1}2-4xLC)/ 1_1 -> 4_4 to Server 01// 01-04
	# 7. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_04_12_23_26}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Location},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)}


	${values_list}    Create List
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,${GBIC_SLOT_1},${01} ${SLASH} ${1-1}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${02} ${SLASH} ${Pair 2},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,${GBIC_SLOT_1},${02} ${SLASH} ${2-2}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${03} ${SLASH} ${Pair 3},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,${GBIC_SLOT_1},${03} ${SLASH} ${3-3}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${04} ${SLASH} ${Pair 4},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,${GBIC_SLOT_1},${04} ${SLASH} ${4-4}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${05} ${SLASH} ${Pair 5},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${06} ${SLASH} ${Pair 6},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${05} ${SLASH} ${Pair 5},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${06} ${SLASH} ${Pair 6},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},,,,,
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${04} ${SLASH} ${Pair 4},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,${GBIC_SLOT_1},${04} ${SLASH} ${4-4}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${03} ${SLASH} ${Pair 3},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,${GBIC_SLOT_1},${03} ${SLASH} ${3-3}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${02} ${SLASH} ${Pair 2},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,${GBIC_SLOT_1},${02} ${SLASH} ${2-2}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,${GBIC_SLOT_1},${01} ${SLASH} ${1-1}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,${GBIC_SLOT_1},${01} ${SLASH} ${1-1}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${02} ${SLASH} ${Pair 2},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,${GBIC_SLOT_1},${02} ${SLASH} ${2-2}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${03} ${SLASH} ${Pair 3},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,${GBIC_SLOT_1},${03} ${SLASH} ${3-3}
	...    ${SWITCH_NAME_1},,${GBIC_SLOT_1},${04} ${SLASH} ${Pair 4},${cabled to},${tree_node_room_1},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},,${GBIC_SLOT_1},${04} ${SLASH} ${4-4}

	${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12    18    19    20    21
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# SM-29975-27-Verify that the customer circuit is displayed correctly: LC Switch -> patched New_6xLC to -> ${MPO1}2 Panel -> cabled to -> ${MPO1}2 Panel -> patched 4xLC to -> LC Server
        
	${building_name}	Set Variable	Building_SM29975_27
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
	
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001:
	# _LC Switch 01
	# _MPO Panel 01
	# _MPO Panel 02
	# _LC Server 01
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from Panel 01// 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
	# 6. Create the Add Patch job and complete the job from:
	# _Panel 01// 01 (${MPO1}2-New_6xLC EB)/ ${Pair 1} -> Pair 6 to Switch 01// 01-06
	# _Panel 02// 01 (${MPO1}2-4xLC)/ 1_1 -> 4_4 to Server 01// 01-04
	# 7. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_03_05_07_19_27_28}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Equipment (2)},${Equipment Card (2)},${Equipment GBIC Slot (2)},${Equipment Port (2)}

	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${1-1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${02} ${SLASH} ${2-2}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${03} ${SLASH} ${3-3}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${BLADE_SERVER_NAME},${CARD_NAME_1},,${04} ${SLASH} ${4-4}
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${tree_node_room_1},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${1-1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${BLADE_SERVER_NAME},${CARD_NAME_1},,${02} ${SLASH} ${2-2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${BLADE_SERVER_NAME},${CARD_NAME_1},,${03} ${SLASH} ${3-3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${BLADE_SERVER_NAME},${CARD_NAME_1},,${04} ${SLASH} ${4-4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${tree_node_room_1},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${1-1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${BLADE_SERVER_NAME},${CARD_NAME_1},,${02} ${SLASH} ${2-2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${BLADE_SERVER_NAME},${CARD_NAME_1},,${03} ${SLASH} ${3-3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${BLADE_SERVER_NAME},${CARD_NAME_1},,${04} ${SLASH} ${4-4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${BLADE_SERVER_NAME},${CARD_NAME_1},,${01} ${SLASH} ${1-1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${BLADE_SERVER_NAME},${CARD_NAME_1},,${02} ${SLASH} ${2-2},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${BLADE_SERVER_NAME},${CARD_NAME_1},,${03} ${SLASH} ${3-3},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${BLADE_SERVER_NAME},${CARD_NAME_1},,${04} ${SLASH} ${4-4},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${patched to},${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4} 

	${rows_list}    Create List    1    2    3    4    5    6    14    15    16    17    18    19    25    26    27    28    29    30    36    37    38    39
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# SM-29975-28-Verify that the customer circuit is displayed correctly: LC Switch -> cabled New_6xLC to -> ${MPO1}2 Panel -> patched to -> ${MPO1}2 Panel -> cabled 4xLC to -> LC Switch
        
	${building_name}	Set Variable	Building_SM29975_28
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${SWITCH_NAME_1}
	
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _LC Switch 01 to Room 01
	# _MPO Panel ${01}, MPO Panel ${02}, LC Switch 02 to Rack 001
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from:
	# _Panel 01// 01 (${MPO1}2-New_6xLC EB)/ ${Pair 1} -> Pair 6 to Switch 01// 01-06
	# _Panel 02// 01 (${MPO1}2-4xLC)/ 1_1 -> 4_4 to Switch 02// 01-04
	# 6. Create the Add Patch job and complete the job from Panel 01// 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
	# 7. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_03_05_07_19_27_28}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_switch_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Equipment (2)},${Equipment Card (2)},${Equipment GBIC Slot (2)},${Equipment Port (2)}

	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${Pair 1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,${GBIC_SLOT_1},${01} ${SLASH} ${1-1}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${Pair 2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,${GBIC_SLOT_1},${02} ${SLASH} ${2-2}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${Pair 3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,${GBIC_SLOT_1},${03} ${SLASH} ${3-3}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${Pair 4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_2},,${GBIC_SLOT_1},${04} ${SLASH} ${4-4}
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,

	${rows_list}    Create List    1    2    3    4    5    6
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_03_05_07_19_27_28}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Location},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)},${Connection (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Equipment (2)},${Equipment Card (2)},${Equipment GBIC Slot (2)},${Equipment Port (2)}

	${values_list}    Create List
	...    ${tree_node_room_1},${SWITCH_NAME_2},,${GBIC_SLOT_1},${01} ${SLASH} ${1-1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,${GBIC_SLOT_1},${02} ${SLASH} ${2-2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,${GBIC_SLOT_1},${03} ${SLASH} ${3-3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,${GBIC_SLOT_1},${04} ${SLASH} ${4-4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,${GBIC_SLOT_1},${01} ${SLASH} ${1-1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,${GBIC_SLOT_1},${02} ${SLASH} ${2-2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,${GBIC_SLOT_1},${03} ${SLASH} ${3-3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,${GBIC_SLOT_1},${04} ${SLASH} ${4-4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_2},,${GBIC_SLOT_1},${01} ${SLASH} ${1-1},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${Pair 1}
	...    ${tree_node_room_1},${SWITCH_NAME_2},,${GBIC_SLOT_1},${02} ${SLASH} ${2-2},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${Pair 2} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,${GBIC_SLOT_1},${03} ${SLASH} ${3-3},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${Pair 3} 
	...    ${tree_node_room_1},${SWITCH_NAME_2},,${GBIC_SLOT_1},${04} ${SLASH} ${4-4},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${cabled to},${SWITCH_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${Pair 4} 
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${Pair 5},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${tree_node_room_1},${SWITCH_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${Pair 6},${cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${SLASH}${A1},${patched to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,

	${rows_list}    Create List    1    2    3    4    7    8    9    10    11    12    18    19    20    21    22    23
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

	# SM-29975-29-Verify that the customer circuit is displayed correctly: LC Switch -> cabled New_6xLC to -> ${MPO1}2 Panel -> patched to -> ${MPO1}2 Panel -> cabled 4xLC to -> LC Switch
       
	${building_name}	Set Variable	Building_SM29975_29
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${SWITCH_NAME_1}
	
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _LC Switch 01 to Room 01
	# _MPO Panel ${01}, MPO Panel ${02}, LC Switch 02 to Rack 001
	# 4. Set Data service for Switch 01// 01-06 directly
	# 5. Cable from:
	# _Panel 01// 01 (${MPO1}2-New_6xLC EB)/ ${Pair 1} -> Pair 6 to Switch 01// 01-06
	# _Panel 02// 01 (${MPO1}2-4xLC)/ 1_1 -> 4_4 to Switch 02// 01-04
	# 6. Create the Add Patch job and complete the job from Panel 01// 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
	# 7. Create Circuit Trace Report and observe the data
    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_06_29}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_switch_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Location},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}

	${values_list}    Create List
	...    ${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${1-1}
	...    ${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${2-2}
	...    ${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${3-3}
	...    ${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${4-4}
	...    ${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,

	${rows_list}    Create List    1    2    3    4    5    6
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

    Select Main Menu    ${Reports}
    View Report    ${REPORT_NAME_SM_29975_06_29}
    Select Filter For Report     selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True} 
    ${headers}    Set Variable    ${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Connection (1)},${Location},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Connection (2)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Connection (3)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}

	${values_list}    Create List
	...    ${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${1-1}
	...    ${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${2-2}
	...    ${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${3-3}
	...    ${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${4-4}
	...    ${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${1-1}
	...    ${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${2-2}
	...    ${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${3-3}
	...    ${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${4-4}
	...    ${SWITCH_NAME_1},,,${05} ${SLASH} ${Pair 5},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${SWITCH_NAME_1},,,${06} ${SLASH} ${Pair 6},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01},,,,,
	...    ${SWITCH_NAME_1},,,${01} ${SLASH} ${Pair 1},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${1-1}
	...    ${SWITCH_NAME_1},,,${02} ${SLASH} ${Pair 2},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${2-2}
	...    ${SWITCH_NAME_1},,,${03} ${SLASH} ${Pair 3},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${3-3}
	...    ${SWITCH_NAME_1},,,${04} ${SLASH} ${Pair 4},${cabled to},${tree_node_room_1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${F2B cabled to},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${patched to},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${4-4}

	${rows_list}    Create List    1    2    3    4    5    6    17    18    19    20    22    23    24    25    26    27
	
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]

(Bulk_SM-29975-30-31-32)_Verify That After Converting DB, The Circuit Trace Report Is Displayed Correctly With Customer Circuit
	[Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
	...    AND    Restore Database    ${TC_SM_29975_30_31_32_FILE_NAME}    ${DIR_FILE_BK}
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Select Main Menu    ${Site Manager}
	...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${building_name}   
    ...    AND    Close Browser
    
    ${building_name}    Set Variable    Building_SM_29975_30_31_32
    ${report_name_sm_29975_30}    Set Variable    SM-29975-30
    ${report_name_sm_29975_31}    Set Variable    SM-29975-31
    ${report_name_sm_29975_32}    Set Variable    SM-29975-32
    ${tree_node_room_1}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_1} ${SLASH} ${ROOM_NAME}
    ${tree_node_room_2}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_2} ${SLASH} ${ROOM_NAME}
    ${tree_node_room_3}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_3} ${SLASH} ${ROOM_NAME}
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tree_node_rack_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_2}/${ROOM_NAME}/${RACK_GROUP_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tree_node_rackgroup_2}    Set Variable    ${SITE_NODE} ${SLASH} ${building_name} ${SLASH} ${FLOOR_NAME_2} ${SLASH} ${ROOM_NAME} ${SLASH} ${RACK_GROUP_NAME}
    ${tree_node_rack_3}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_3}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tree_node_switch_1}    Set Variable    ${tree_node_rack_1}/${SWITCH_NAME_3}
    ${tree_node_switch_2}    Set Variable    ${tree_node_rack_2}/${SWITCH_NAME_1}
    ${tree_node_switch_3}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_3}/${ROOM_NAME}/${SWITCH_NAME_1}
    
    ### SM-29975-30: Verify that after converting DB, the circuit trace report is displayed correctly with customer circuit: LC Switch -> patched 6xLC to -> ${MPO1}2 Panel -> cabled to -> ${MPO1}2 Panel -> patched 6xLC to -> LC Server
    # 1. Prepare two test machines:
    # _Machine 1: Install the previous SM Build (e.g. SM9.1) which has not supported new 6xLC assembly in purple yet
	# _Machine 2: Install the latest SM Build
	# 2. Launch and log into SM Web of machine 1
	# 3. Go to "Site Manager" page
	# 4. Add to Rack 001:
	# _LC Switch 01
	# _MPO Panel 01
	# _MPO Panel 02
	# _LC Server 01
	# 5. Set Data service for Switch 01// 01-06 directly
	# 6. Cable from Panel 01// 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
	# 7. Create the Add Patch job and complete the job from:
	# _Panel 01// 01 (${MPO1}2-6xLC)/ A1-2 -> A11_12 to Switch 01// 01-06
	# _Panel 02// 01 (${MPO1}2-6xLC)/ A1-2 -> A11_12 to Server 01// 01-06
    # 8. Backup this DB then restore this DB to machine 2 successfully
    # 9. Launch and log into SM Web of machine 2
    # 10. Create Circuit Trace Report and observe the data
    # The Data is displayed correctly
    Select Main Menu    ${Reports}
    View Report    ${report_name_sm_29975_30}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_rack_1}    clickViewBtn=${True}
    
    ${headers}    Set Variable    ${Location},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Equipment (2)},${Equipment Card (2)},${Equipment GBIC Slot (2)},${Equipment Port (2)}
	${values_list}    Create List
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${A11-12},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${01} ${SLASH} ${A1-2}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${A9-10},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${02} ${SLASH} ${A3-4}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${A7-8},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${03} ${SLASH} ${A5-6}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${A5-6},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${04} ${SLASH} ${A7-8}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${A3-4},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${05} ${SLASH} ${A9-10}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1-2},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${06} ${SLASH} ${A11-12}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${A11-12},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${01} ${SLASH} ${A1-2}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${A9-10},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${02} ${SLASH} ${A3-4}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${A7-8},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${03} ${SLASH} ${A5-6}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${A5-6},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${04} ${SLASH} ${A7-8}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${A3-4},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${05} ${SLASH} ${A9-10}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1-2},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${06} ${SLASH} ${A11-12}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1-2},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${06} ${SLASH} ${A11-12}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${A3-4},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${05} ${SLASH} ${A9-10}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${A5-6},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${04} ${SLASH} ${A7-8}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${A7-8},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${03} ${SLASH} ${A5-6}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${A9-10},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${02} ${SLASH} ${A3-4}
	...    ${tree_node_room_1},${SERVER_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${A11-12},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${SWITCH_NAME_3},,,${01} ${SLASH} ${A1-2}
	...    ${tree_node_room_1},${SWITCH_NAME_3},,,${01} ${SLASH} ${A1-2},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${SERVER_NAME_1},${CARD_NAME_1},,${06} ${SLASH} ${A11-12}
	...    ${tree_node_room_1},${SWITCH_NAME_3},,,${02} ${SLASH} ${A3-4},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${SERVER_NAME_1},${CARD_NAME_1},,${05} ${SLASH} ${A9-10}
	...    ${tree_node_room_1},${SWITCH_NAME_3},,,${03} ${SLASH} ${A5-6},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${SERVER_NAME_1},${CARD_NAME_1},,${04} ${SLASH} ${A7-8}
	...    ${tree_node_room_1},${SWITCH_NAME_3},,,${04} ${SLASH} ${A7-8},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${SERVER_NAME_1},${CARD_NAME_1},,${03} ${SLASH} ${A5-6}
	...    ${tree_node_room_1},${SWITCH_NAME_3},,,${05} ${SLASH} ${A9-10},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${SERVER_NAME_1},${CARD_NAME_1},,${02} ${SLASH} ${A3-4}
	...    ${tree_node_room_1},${SWITCH_NAME_3},,,${06} ${SLASH} ${A11-12},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1},${01} ${SLASH} ${A1},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${SERVER_NAME_1},${CARD_NAME_1},,${01} ${SLASH} ${A1-2}
    ${rows_list}    Create List    1    2    3    4    5    6    30    31    32    33    34    35
    ...    59    60    61    62    63    64    65    66    67    68    69    70

    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]  

    ### SM-29975-31: Verify that after converting DB, the circuit trace report is displayed correctly with customer circuit: LC Switch -> cabled 6xLC to -> ${MPO1}2 Panel -> F2B cabling to -> ${MPO1}2 Panel -> patched 6xLC to -> LC Server
    # 1. Prepare two test machines:
	# _Machine 1: Install the previous SM Build (e.g. SM9.1)
	# _Machine 2: Install the latest SM Build
	# 2. Launch and log into SM Web of machine 1
	# 3. Go to "Site Manager" page
	# 4. Add:
	# _LC Switch 01 to Room 01
	# _MPO non-iPatch Panel 01 to Rack 001
	# _MPO Panel ${02}, LC Server 01 to Rack 001
	# 5. Set Data service for Switch 01// 01-06 directly
	# 6. Cable from Panel 01// 01 (${MPO1}2-6xLC)/ A1-2 -> A11_12 to Switch 01// 01-06
	# 7. F2B cabling from Panel 01// 01 (${MPO1}2-${MPO1}2) to Panel 02// 01
	# 8. Create the Add Patch job and complete the job from Panel 02// 01 (${MPO1}2-6xLC)/ A1-2 -> A11_12 to Server 01// 01-06
	# 9. Backup this DB then restore this DB to machine 2 successfully
	# 10. Launch and log into SM Web of machine 2
	# 11. Create Circuit Trace Report and observe the data
	# The Data is displayed correctly
    Select Main Menu    ${Reports}
    View Report    ${report_name_sm_29975_31}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_rack_2}    clickViewBtn=${True}

	${headers}    Set Variable    ${Server ID},${Server Card},${Server GBIC Slot},${Server Port},${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Location},${Equipment (1)},${Equipment Card (1)},${Equipment GBIC Slot (1)},${Equipment Port (1)},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Room (2)},${Rack Group (2)},${Zone ID (2)},${Rack Position (2)},${Rack (2)},${Panel (2)},${Panel Port (2)},${Equipment (2)},${Equipment Card (2)},${Equipment GBIC Slot (2)},${Equipment Port (2)}
	${values_list}    Create List
	...    ${SERVER_NAME_1},,,${06} ${SLASH} ${A11-12},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01} ${SLASH} ${A1-2},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},,,,
	...    ${SERVER_NAME_1},,,${05} ${SLASH} ${A9-10},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02} ${SLASH} ${A3-4},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},,,,
	...    ${SERVER_NAME_1},,,${04} ${SLASH} ${A7-8},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03} ${SLASH} ${A5-6},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},,,,
	...    ${SERVER_NAME_1},,,${03} ${SLASH} ${A5-6},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04} ${SLASH} ${A7-8},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},,,,
	...    ${SERVER_NAME_1},,,${02} ${SLASH} ${A3-4},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05} ${SLASH} ${A9-10},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},,,,
	...    ${SERVER_NAME_1},,,${01} ${SLASH} ${A1-2},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06} ${SLASH} ${A11-12},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},,,,
	...    ${SERVER_NAME_1},,,${06} ${SLASH} ${A11-12},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01} ${SLASH} ${A1-2},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${05} ${SLASH} ${A9-10},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02} ${SLASH} ${A3-4},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${04} ${SLASH} ${A7-8},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03} ${SLASH} ${A5-6},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${03} ${SLASH} ${A5-6},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04} ${SLASH} ${A7-8},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${02} ${SLASH} ${A3-4},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05} ${SLASH} ${A9-10},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${01} ${SLASH} ${A1-2},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06} ${SLASH} ${A11-12},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${06} ${SLASH} ${A11-12},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01} ${SLASH} ${A1-2},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${05} ${SLASH} ${A9-10},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02} ${SLASH} ${A3-4},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${04} ${SLASH} ${A7-8},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03} ${SLASH} ${A5-6},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${03} ${SLASH} ${A5-6},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04} ${SLASH} ${A7-8},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${02} ${SLASH} ${A3-4},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05} ${SLASH} ${A9-10},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${01} ${SLASH} ${A1-2},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06} ${SLASH} ${A11-12},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${01} ${SLASH} ${A1-2},${SWITCH_NAME_1},,${GBIC_SLOT_1},${06} ${SLASH} ${A11-12},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${02} ${SLASH} ${A3-4},${SWITCH_NAME_1},,${GBIC_SLOT_1},${05} ${SLASH} ${A9-10},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${03} ${SLASH} ${A5-6},${SWITCH_NAME_1},,${GBIC_SLOT_1},${04} ${SLASH} ${A7-8},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${04} ${SLASH} ${A7-8},${SWITCH_NAME_1},,${GBIC_SLOT_1},${03} ${SLASH} ${A5-6},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${05} ${SLASH} ${A9-10},${SWITCH_NAME_1},,${GBIC_SLOT_1},${02} ${SLASH} ${A3-4},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
	...    ${SERVER_NAME_1},,,${06} ${SLASH} ${A11-12},${SWITCH_NAME_1},,${GBIC_SLOT_1},${01} ${SLASH} ${A1-2},${tree_node_rackgroup_2},,,,,${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_2},${01} ${SLASH} ${A1},${ROOM_NAME},${RACK_GROUP_NAME},${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Pass-Through}),${01} ${SLASH} ${SLASH}${A1},,,,
    ${rows_list}    Create List    1    2    3    4    5    6    13    14    15    16    17    18
    ...    50    51    52    53    54    55    79    80    81    82    83    84

    :FOR    ${i}    IN RANGE    0    len(${values_list})
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	
    ### SM-29975-32: Verify that after converting DB, the circuit trace report is displayed correctly with customer circuit: LC Switch -> cabled 6xLC to -> HSM -> patched to -> LC Server
    # 1. Prepare two test machines:
	# _Machine 1: Install the previous SM Build (e.g. SM9.1)
	# _Machine 2: Install the latest SM Build
	# 2. Launch and log into SM Web of machine 1
	# 3. Go to "Site Manager" page
	# 4. Add:
	# _LC Switch 01 to Room 01
	# _HSM Panel 01 (Alpha/Beta), LC Server 01 to Rack 001
	# 5. Set Data service for Switch 01// 01-06 directly
	# 6. Cable from Panel 01// MPO 01 (${MPO1}2-6xLC)/ A1-2 -> A11_12 to Switch 01// 01-06
	# 7. Create the Add Patch job and complete the job from Panel 01// 01-06 to Server 01// 01-06
	# 8. Backup this DB then restore this DB to machine 2 successfully
	# 9. Launch and log into SM Web of machine 2
	# 10. Create Circuit Trace Report and observe the data
	# The Data is displayed correctly
    Select Main Menu    ${Reports}
    View Report    ${report_name_sm_29975_32}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_switch_3}    clickViewBtn=${True}

	${headers}    Set Variable    ${Switch},${Switch Card},${Switch GBIC Slot},${Switch Port},${Location},${Room (1)},${Rack Group (1)},${Zone ID (1)},${Rack Position (1)},${Rack (1)},${Panel (1)},${Panel Port (1)},${Server ID},${Server Card},${Server GBIC Slot},${Server Port}
	${values_list}    Create List
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${01},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${01},${SERVER_NAME_1},${CARD_NAME_1},,${01}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${02},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${02},${SERVER_NAME_1},${CARD_NAME_1},,${02}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${03},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${03},${SERVER_NAME_1},${CARD_NAME_1},,${03}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${04},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${04},${SERVER_NAME_1},${CARD_NAME_1},,${04}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${05},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${05},${SERVER_NAME_1},${CARD_NAME_1},,${05}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${06},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${06},${SERVER_NAME_1},${CARD_NAME_1},,${06}
	${rows_list}    Create List    1    2    3    4    5    6

    :FOR    ${i}    IN RANGE    0    len(${values_list})
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
    
	Select Main Menu    ${Reports}
    View Report    ${report_name_sm_29975_32}
    Select Filter For Report    selectLocationType=Check    treeNode=${tree_node_rack_3}    clickViewBtn=${True}
	${values_list}    Create List
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${01},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${01},${SERVER_NAME_1},${CARD_NAME_1},,${01}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${02},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${02},${SERVER_NAME_1},${CARD_NAME_1},,${02}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${03},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${03},${SERVER_NAME_1},${CARD_NAME_1},,${03}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${04},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${04},${SERVER_NAME_1},${CARD_NAME_1},,${04}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${05},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${05},${SERVER_NAME_1},${CARD_NAME_1},,${05}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${06},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${06},${SERVER_NAME_1},${CARD_NAME_1},,${06}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${01},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${01},${SERVER_NAME_1},${CARD_NAME_1},,${01}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${02},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${02},${SERVER_NAME_1},${CARD_NAME_1},,${02}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${03},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${03},${SERVER_NAME_1},${CARD_NAME_1},,${03}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${04},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${04},${SERVER_NAME_1},${CARD_NAME_1},,${04}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${05},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${05},${SERVER_NAME_1},${CARD_NAME_1},,${05}
	...    ${SWITCH_NAME_1},${CARD_NAME_1},,${06},${tree_node_room_3},${ROOM_NAME},,${ZONE},${POSITION},${RACK_NAME},${PANEL_NAME_1} ${SLASH} ${Module 1A} (${Alpha}),${06},${SERVER_NAME_1},${CARD_NAME_1},,${06}
    ${rows_list}    Create List    1    2    3    4    5    6    85    86    87    88    89    90

    :FOR    ${i}    IN RANGE    0    len(${values_list})
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
    