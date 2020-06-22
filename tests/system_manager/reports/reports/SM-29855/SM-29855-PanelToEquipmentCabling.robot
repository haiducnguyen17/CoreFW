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
${FLOOR_NAME}    Panel to Equipment Cabling
${RACK_NAME}    Rack 001
${SWITCH_NAME}    Switch 01
${SWITCH_NAME_2}    Switch 02
${PANEL_NAME}    Panel 01
${PANEL_NAME_2}    Panel 02
${MODULE_DM8}    Module 1A (DM08)
${MODULE_DM12}    Module 1A (DM12)
${RESTORE_FILE_NAME}    DB SM-29855.bak

*** Test Cases ***
SM-29855_TC16,17,18,19,20,21_Verify that Panel to Equipment Reports shows data correctly for new 6xLC EB in circuit
    
    [Tags]    Sanity

    ${report_name}    Set Variable    Panel to Equipment Cabling
    ${room_name_16}    Set Variable    TC_16
    ${room_name_17}    Set Variable    TC_17
    ${room_name_18}    Set Variable    TC_18
    ${room_name_19}    Set Variable    TC_19
    ${room_name_20}    Set Variable    TC_20
    ${room_name_21}    Set Variable    TC_21
    ${rack_16}    Set Variable    Rack 016
    ${rack_17}    Set Variable    Rack 017
    ${rack_18}    Set Variable    Rack 018
    ${rack_19}    Set Variable    Rack 019
    ${rack_20}    Set Variable    Rack 020
    ${rack_21}    Set Variable    Rack 021
    ${mpo_01}    Set Variable    MPO 01
    ${tree_node_rack16_report}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_16} / 1:1 ${rack_16}
    ${tree_node_rack17_report}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_17} / 1:1 ${rack_17}
    ${tree_node_rack18_report}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_18} / 1:1 ${rack_18}
    ${tree_node_rack19_report}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_19} / 1:1 ${rack_19}
    ${tree_node_rack20_report}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_20} / 1:1 ${rack_20}
    ${tree_node_rack21_report}    Set Variable    ${SITE_NODE} / ${BUILDING_NAME} / ${FLOOR_NAME} / ${room_name_21} / 1:1 ${rack_21}
    
    # 1. Add:
	# _Building 01/Floor 01/Room 01/1:1 Rack 001
	# 2. Create Circuit as below:
	# _LC Switch 01/01-06 -cabled 6xLC EB to-> MPO12 Panel 01/01 -patched to-> MPO12 Panel 02/01-cabled 4xLC to-> LC Switch 02/01-04
	# _LC Switch 01/01-06 <-cabled 6xLC EB to- DM08 Panel 01/01-06(MPO 01) -patched to->LC Server 01/01-06
	# _LC Switch 01/01-06 <-Cabled 6xLC EB to- DM12 Panel 01/01-06 -patched to-> DM12 Panel/01-06 -Cabled 6xLC EB-> LC Switch 02/01-06
	# _LC Switch 01/01-06 -patched to-> DM12 Panel 01/01-06 (MPO 01) <-F2B MPO12- MPO Panel 02/01 -cabled 6xLC EB to-> LC Switch 02/01-06
	# _MPO24 Switch 01/01 -patched 3xMPO12-> MPO Panel 01 -cabled 6xLC EB to-> LC Switch 02/01-06 
	# _LC Switch 01/01-06 -patched to-> DM12 Panel 01/01-06 (MPO 01) -cabled 6xLC EB to-> LC Switch 02/01-06
	# 3. Go to Reports, Create "Cabling->Panel to Equipment Cabling" report with data as below:
	# _Location (Panel), Panel Name, Panel Port, Location (Equipment), Equipment Name, Card, GBIC, Equipment Port, Equipment Port Status, Port Type
	# 4. Check Result on View Report page with Location is current Building 
    Select Main Menu    ${Reports}
    View Report    ${report_name}
    Select Filter For Report    selectLocationType=Check    treeNode=${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}    clickViewBtn=${True}
    Sort View Report Table By Column Name    Location (Panel)    typeSort=desc
    Sort View Report Table By Column Name    Location (Panel)    typeSort=asc
    ${headers}    Set Variable    Location (Panel),Panel Name,Panel Port,Location (Equipment),Equipment Name,Card,GBIC,Equipment Port,Equipment Port Status,Port Type
    ${values_list}    Create List
    ...    ${tree_node_rack16_report},${PANEL_NAME},${Port 01} / ${Pair 1},${tree_node_rack16_report},${SWITCH_NAME},,,${Port 01},${In Use},${MPO}
    ...    ${tree_node_rack16_report},${PANEL_NAME},${Port 01} / ${Pair 2},${tree_node_rack16_report},${SWITCH_NAME},,,${Port 02},${In Use},${MPO}
    ...    ${tree_node_rack16_report},${PANEL_NAME},${Port 01} / ${Pair 3},${tree_node_rack16_report},${SWITCH_NAME},,,${Port 03},${In Use},${MPO}
    ...    ${tree_node_rack16_report},${PANEL_NAME},${Port 01} / ${Pair 4},${tree_node_rack16_report},${SWITCH_NAME},,,${Port 04},${In Use},${MPO}
    ...    ${tree_node_rack16_report},${PANEL_NAME},${Port 01} / ${Pair 5},${tree_node_rack16_report},${SWITCH_NAME},,,${Port 05},${In Use},${MPO}
    ...    ${tree_node_rack16_report},${PANEL_NAME},${Port 01} / ${Pair 6},${tree_node_rack16_report},${SWITCH_NAME},,,${Port 06},${In Use},${MPO}
    ...    ${tree_node_rack16_report},${PANEL_NAME_2},${Port 01} / ${1-1},${tree_node_rack16_report},${SWITCH_NAME_2},,,${Port 01},${In Use},${MPO}
    ...    ${tree_node_rack16_report},${PANEL_NAME_2},${Port 01} / ${2-2},${tree_node_rack16_report},${SWITCH_NAME_2},,,${Port 02},${In Use},${MPO}
    ...    ${tree_node_rack16_report},${PANEL_NAME_2},${Port 01} / ${3-3},${tree_node_rack16_report},${SWITCH_NAME_2},,,${Port 03},${In Use},${MPO}
    ...    ${tree_node_rack16_report},${PANEL_NAME_2},${Port 01} / ${4-4},${tree_node_rack16_report},${SWITCH_NAME_2},,,${Port 04},${In Use},${MPO}
    ...    ${tree_node_rack17_report},${PANEL_NAME} / ${MODULE_DM8},${MPO1-01},${tree_node_rack17_report},${SWITCH_NAME},,,${Port 01},${In Use},${LC}
    ...    ${tree_node_rack17_report},${PANEL_NAME} / ${MODULE_DM8},${MPO1-02},${tree_node_rack17_report},${SWITCH_NAME},,,${Port 02},${In Use},${LC}
    ...    ${tree_node_rack17_report},${PANEL_NAME} / ${MODULE_DM8},${MPO1-03},${tree_node_rack17_report},${SWITCH_NAME},,,${Port 03},${In Use},${LC}
    ...    ${tree_node_rack17_report},${PANEL_NAME} / ${MODULE_DM8},${MPO1-04},${tree_node_rack17_report},${SWITCH_NAME},,,${Port 04},${In Use},${LC}
    ...    ${tree_node_rack17_report},${PANEL_NAME} / ${MODULE_DM8},${mpo_01} / ${Pair 5},${tree_node_rack17_report},${SWITCH_NAME},,,${Port 05},${Available},${MPO}
    ...    ${tree_node_rack17_report},${PANEL_NAME} / ${MODULE_DM8},${mpo_01} / ${Pair 6},${tree_node_rack17_report},${SWITCH_NAME},,,${Port 06},${Available},${MPO}
    ...    ${tree_node_rack18_report},${PANEL_NAME} / ${MODULE_DM12},${Port 01},${tree_node_rack18_report},${SWITCH_NAME},,,${Port 01},${In Use},${LC}
    ...    ${tree_node_rack18_report},${PANEL_NAME} / ${MODULE_DM12},${Port 02},${tree_node_rack18_report},${SWITCH_NAME},,,${Port 02},${In Use},${LC}
    ...    ${tree_node_rack18_report},${PANEL_NAME} / ${MODULE_DM12},${Port 03},${tree_node_rack18_report},${SWITCH_NAME},,,${Port 03},${In Use},${LC}
    ...    ${tree_node_rack18_report},${PANEL_NAME} / ${MODULE_DM12},${Port 04},${tree_node_rack18_report},${SWITCH_NAME},,,${Port 04},${In Use},${LC}
    ...    ${tree_node_rack18_report},${PANEL_NAME} / ${MODULE_DM12},${Port 05},${tree_node_rack18_report},${SWITCH_NAME},,,${Port 05},${In Use},${LC}
    ...    ${tree_node_rack18_report},${PANEL_NAME} / ${MODULE_DM12},${Port 06},${tree_node_rack18_report},${SWITCH_NAME},,,${Port 06},${In Use},${LC}
    ...    ${tree_node_rack18_report},${PANEL_NAME_2} / ${MODULE_DM12},${Port 01},${tree_node_rack18_report},${SWITCH_NAME_2},,,${Port 01},${In Use},${LC}
    ...    ${tree_node_rack18_report},${PANEL_NAME_2} / ${MODULE_DM12},${Port 02},${tree_node_rack18_report},${SWITCH_NAME_2},,,${Port 02},${In Use},${LC}
    ...    ${tree_node_rack18_report},${PANEL_NAME_2} / ${MODULE_DM12},${Port 03},${tree_node_rack18_report},${SWITCH_NAME_2},,,${Port 03},${In Use},${LC}
    ...    ${tree_node_rack18_report},${PANEL_NAME_2} / ${MODULE_DM12},${Port 04},${tree_node_rack18_report},${SWITCH_NAME_2},,,${Port 04},${In Use},${LC}
    ...    ${tree_node_rack18_report},${PANEL_NAME_2} / ${MODULE_DM12},${Port 05},${tree_node_rack18_report},${SWITCH_NAME_2},,,${Port 05},${In Use},${LC}
    ...    ${tree_node_rack18_report},${PANEL_NAME_2} / ${MODULE_DM12},${Port 06},${tree_node_rack18_report},${SWITCH_NAME_2},,,${Port 06},${In Use},${LC}
    ...    ${tree_node_rack19_report},${PANEL_NAME_2},${Port 01} / ${Pair 1},${tree_node_rack19_report},${SWITCH_NAME_2},,,${Port 01},${In Use},${MPO}
    ...    ${tree_node_rack19_report},${PANEL_NAME_2},${Port 01} / ${Pair 2},${tree_node_rack19_report},${SWITCH_NAME_2},,,${Port 02},${In Use},${MPO}
    ...    ${tree_node_rack19_report},${PANEL_NAME_2},${Port 01} / ${Pair 3},${tree_node_rack19_report},${SWITCH_NAME_2},,,${Port 03},${In Use},${MPO}
    ...    ${tree_node_rack19_report},${PANEL_NAME_2},${Port 01} / ${Pair 4},${tree_node_rack19_report},${SWITCH_NAME_2},,,${Port 04},${In Use},${MPO}
    ...    ${tree_node_rack19_report},${PANEL_NAME_2},${Port 01} / ${Pair 5},${tree_node_rack19_report},${SWITCH_NAME_2},,,${Port 05},${In Use},${MPO}
    ...    ${tree_node_rack19_report},${PANEL_NAME_2},${Port 01} / ${Pair 6},${tree_node_rack19_report},${SWITCH_NAME_2},,,${Port 06},${In Use},${MPO}
    ...    ${tree_node_rack20_report},${PANEL_NAME},${Port 01} / ${Pair 1},${tree_node_rack20_report},${SWITCH_NAME_2},,,${Port 01},${In Use},${MPO}
    ...    ${tree_node_rack20_report},${PANEL_NAME},${Port 01} / ${Pair 2},${tree_node_rack20_report},${SWITCH_NAME_2},,,${Port 02},${In Use},${MPO}
    ...    ${tree_node_rack20_report},${PANEL_NAME},${Port 01} / ${Pair 3},${tree_node_rack20_report},${SWITCH_NAME_2},,,${Port 03},${In Use},${MPO}
    ...    ${tree_node_rack20_report},${PANEL_NAME},${Port 01} / ${Pair 4},${tree_node_rack20_report},${SWITCH_NAME_2},,,${Port 04},${In Use},${MPO}
    ...    ${tree_node_rack20_report},${PANEL_NAME},${Port 01} / ${Pair 5},${tree_node_rack20_report},${SWITCH_NAME_2},,,${Port 05},${In Use},${MPO}
    ...    ${tree_node_rack20_report},${PANEL_NAME},${Port 01} / ${Pair 6},${tree_node_rack20_report},${SWITCH_NAME_2},,,${Port 06},${In Use},${MPO}
    ...    ${tree_node_rack21_report},${PANEL_NAME} / ${MODULE_DM12},${Port 01},${tree_node_rack21_report},${SWITCH_NAME_2},,,${Port 01},${In Use},${LC}
    ...    ${tree_node_rack21_report},${PANEL_NAME} / ${MODULE_DM12},${Port 02},${tree_node_rack21_report},${SWITCH_NAME_2},,,${Port 02},${In Use},${LC}
    ...    ${tree_node_rack21_report},${PANEL_NAME} / ${MODULE_DM12},${Port 03},${tree_node_rack21_report},${SWITCH_NAME_2},,,${Port 03},${In Use},${LC}
    ...    ${tree_node_rack21_report},${PANEL_NAME} / ${MODULE_DM12},${Port 04},${tree_node_rack21_report},${SWITCH_NAME_2},,,${Port 04},${In Use},${LC}
    ...    ${tree_node_rack21_report},${PANEL_NAME} / ${MODULE_DM12},${Port 05},${tree_node_rack21_report},${SWITCH_NAME_2},,,${Port 05},${In Use},${LC}
    ...    ${tree_node_rack21_report},${PANEL_NAME} / ${MODULE_DM12},${Port 06},${tree_node_rack21_report},${SWITCH_NAME_2},,,${Port 06},${In Use},${LC}

    ${rows_list}    Create List    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29    30    31    32    33    34    35    36    37    38    39    40    41    42    43    44    45    46
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Report Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]