*** Settings ***
Resource    ../../../../../resources/constants.robot
Resource    ../../../../../resources/icons_constants.robot

Library   ../../../../../py_sources/logigear/setup.py
Library   ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD} 
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py        
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py       
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/work_order_queue/WorkOrderQueuePage${PLATFORM}.py

Default Tags    Connectivity
Force Tags    SM-29556         

Suite Setup    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${Quareo Discovery Folder}

Suite Teardown    Close Browser

*** Variables ***
${FLOOR_NAME}    Floor 01
${ROOM_NAME}    Room 01
${RACK_NAME}    Rack 001
${POSITION_RACK_NAME}    1:1 Rack 001
${PANEL_NAME_1}    MPO Panel 01
${PANEL_NAME_2}    MPO Panel 02
${SWITCH_NAME_1}    LC Switch 01
${SWITCH_NAME_2}    LC Switch 02
${SERVER_NAME_1}    Server 01
${MODULE_1A_ALPHA}    ${Module 1A} (${Alpha})
${MODULE_1A_BETA}    ${Module 1A} (${Beta})
${MPO 01}    MPO 01

*** Test Cases ***
SM-29556-01_Verify that the correct routing for branch connection is shown on Trace window in circuit: Switch -> patched (6xLC-MPO12) to -> Panel 01 -> cabled (MPO12-MPO12) to -> Panel 02 -> patched (MPO12-6xLC) to -> Switch
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29556_01
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Reload Page 
    [Teardown]    Run Keyword    Delete Building    name=${building_name}
      
    ${tc_wo_name}    Set Variable    WO_SM29556_01
    
    # 1. Launch and log into SM Web
	# 2.In SM, add objects:
    # _MPO Panel 01
    # _MPO Panel 02
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME_1}    portType=${MPO}    quantity=2
    
    # _Switch 01 with some LC ports
    # _Switch 02 with some LC ports
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_1}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}    name=${01}    portType=${LC}    quantity=6    
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_2}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${01}    portType=${LC}    quantity=6
    
	# 3. Open Cabling window, cable from:
    # _Panel 01/01 (MPO12-MPO12) to Panel 02/01
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${MPO12}    ${Mpo12_Mpo12}    portsTo=${01}
    Close Cabling Window  
    
	# 4. Open Patching window, patch from:
    # _Panel 01/01 (MPO12-6xLC) to Switch 01/01->06
    # _Panel 02/01 (MPO12-6xLC) to Switch 02/01->06
    # Do not Complete this job
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC}    mpoBranches=${A1-2},${A3-4},${A5-6},${A7-8},${A9-10},${A11-12}    createWo=yes    clickNext=${FALSE}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC}    mpoBranches=${A1-2},${A3-4},${A5-6},${A7-8},${A9-10},${A11-12}    createWo=yes    clickNext=${TRUE}
    Create Work Order    ${tc_wo_name}
    
    # 5. Trace ports in circuit and observe 
    # Trace window should be shown as below:
    # + Current View:
    # _Panel 01, Panel 02: Panel 01/01 -> cable to -> Panel 02/01
    # _Switch 01: Switch 01->06
    # _Switch 02: Switch 02->06
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01}    
    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}   
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    # + Scheduled View:
    # _Panel 01, Panel 02, Switch 01, Switch 02: Switch 01/01 [A1-2] - 06 [A11-12] -> patched to -> Panel 01/01 [A1] -> cabled (MPO12-MPO12) to -> Panel 02/01 [A1] -> patched (MPO12-6xLC) to -> Switch 02/06 [A11-12] - 01 [A1-2]
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01} 
    Select View Type On Trace    Scheduled
   
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}       
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
    ${pair_list}	Create List    ${A1-2}    ${A3-4}    ${A5-6}    ${A7-8}    ${A9-10}    ${A11-12}    
    ${j}    Evaluate    len(${port_list})-1
    
    :FOR    ${i}    IN RANGE    0    len(${port_list})
	    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}/${port_list}[${i}]
        ...    objectType=${TRACE_SWITCH_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_LC_6X_MPO12_PATCHING} 
        \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
        \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_6X_LC_PATCHING}
        \    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${object_position_list}[${j}] [${pair_list}[${j}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${port_list}[${j}]
        ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list}[${j}]->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_ASSIGN_CABLING}
        \    ${j}    Evaluate    ${j}-1    
    Close Trace Window
       
    # 6. Complete Job at step 4
    Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue

    # 7. Trace port in circuit and observe
    # Trace window should be shown as below:
    # + Current View:
    # _Panel 01, Panel 02, Switch 01, Switch 02: Switch 01/01 [A1-2] -> 06 [A11-12] -> patched to -> Panel 01/01 [A1] -> cabled (MPO12-MPO12) to -> Panel 02/01 [A1] -> patched (MPO12-6xLC) to -> Switch 02/06 [A11-12] -> 01 [A1-2]
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01}
    ${j}    Evaluate    len(${port_list})-1
    :FOR    ${i}    IN RANGE    0    len(${port_list})
	    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}/${port_list}[${i}]
        ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_LC_6X_MPO12_PATCHING} 
        \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
        \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_6X_LC_PATCHING}
        \    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${object_position_list}[${j}] [${pair_list}[${j}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${port_list}[${j}]
        ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list}[${j}]->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_ASSIGN_CABLING}
        \    ${j}    Evaluate    ${j}-1    
    Close Trace Window
    
SM-29556-03_Verify that the correct routing for branch connection is shown on Trace window in circuit: Alpha Panel -> cabled to -> MPO Generic Panel -> patched (MPO12-6xLC) to -> Server 01
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29556_03
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Reload Page 
    [Teardown]    Run Keyword    Delete Building    name=${building_name}  
    
    [Tags]    Sanity

    ${tc_wo_name}    Set Variable    WO_SM29556_03
    ${alpha_lc_panel_name}    Set Variable    Alpha LC Panel 01
    
    # 1. Launch and log into SM Web
	# 2.In SM, add objects:
    # _Alpha LC Panel 01
    # _MPO Generic Panel 02
    # _LC Server 03
    ${multi_module_list}    Set Variable    Module 1A,${TRUE},LC 12 Port,Alpha;Module 1B,${FALSE};Module 1C,${FALSE};Module 1D,${FALSE}
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 Fiber Shelf (1U)}    ${alpha_lc_panel_name}    ${multi_module_list}    
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME_2}    portType=${MPO}    quantity=1
    Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SERVER_NAME_1}
    Add Device In Rack Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}    01    portType=${LC}    quantity=6     

	# 3. Open Cabling window, cable from:
    # _Panel 01/01 (MPO12-MPO12) to Panel 02/01
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${alpha_lc_panel_name}
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${alpha_lc_panel_name}/${MODULE_1A_ALPHA}/${MPO 01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${MPO12}    ${Mpo12_Mpo12}    portsTo=${01}
    Close Cabling Window  
    
	# 4. Open Patching window, patch from:
    # _Panel 02/01 (MPO12-6xLC) to Server 01/01->06
    # Do not Complete this job
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${01}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC}    mpoBranches=${A1-2},${A3-4},${A5-6},${A7-8},${A9-10},${A11-12}    createWo=yes    clickNext=${TRUE}
    Create Work Order    ${tc_wo_name}
    
    # 5. Trace window should be shown as below:
    # + Current View:
    # _Panel 01, Panel 02: Panel 01/01->06 (MPO1) -> cable to -> Panel 02/01
    # _Server 01: Server 01/01->06
    
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}       
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
    ${pair_list}	Create List    ${A1-2}    ${A3-4}    ${A5-6}    ${A7-8}    ${A9-10}    ${A11-12}    

    :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${alpha_lc_panel_name}/${MODULE_1A_ALPHA}    ${port_list}[${i}] 
        \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${object_position_list}[${i}] (${MPO1})    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${alpha_lc_panel_name}/${MODULE_1A_ALPHA}/${port_list}[${i}]
        ...    objectType=${Trace 360 instapatch Fiber Shelf}    informationDevice=${port_list}[${i}]->${MODULE_1A_ALPHA}->${alpha_lc_panel_name}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}   
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        \    Close Trace Window
    
    # + Scheduled View:
    # _Panel 01, Panel 02, Server 01: Server 01/01 [A1-2] - 06 [A11-12] -> patched (6xLC-MPO12) to -> Panel 02/01 [A1] -> cabled to -> Panel 01/06 (MPO1)- 01(MPO1)
    
    ${port_list_rev}    Reverse List    ${port_list}      
    ${object_position_list_rev}    Reverse List    ${object_position_list}
    ${pair_list_rev}    Reverse List    ${pair_list}
    
    :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}    ${port_list}[${i}]
        \    Select View Type On Trace    Scheduled
        \    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${object_position_list_rev}[${i}] (${MPO1})     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${alpha_lc_panel_name}/${MODULE_1A_ALPHA}/${port_list_rev}[${i}]
        ...    objectType=${Trace 360 instapatch Fiber Shelf}    informationDevice=${port_list_rev}[${i}]->${MODULE_1A_ALPHA}->${alpha_lc_panel_name}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING} 
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_6X_LC_PATCHING}
        \    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}/${port_list}[${i}]
        ...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        \    Close Trace Window
        
    # 6. Complete Job at step 4
    Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue

    # 7. Trace port in circuit and observe
    # Trace window should be shown as below:
    # + Current View:
    # _Panel 01, Panel 02, Server 01: Server 01/01 [A1-2] -> 06 [A11-12] -> patched (6xLC-MPO12) to -> Panel 02/01 [A1] -> cabled to -> Panel 01/06 (MPO1)->01(MPO1)
    :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}    ${port_list}[${i}]
        \    Select View Type On Trace    Scheduled
        \    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${object_position_list_rev}[${i}] (${MPO1})     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${alpha_lc_panel_name}/${MODULE_1A_ALPHA}/${port_list_rev}[${i}]
        ...    objectType=${Trace 360 instapatch Fiber Shelf}    informationDevice=${port_list_rev}[${i}]->${MODULE_1A_ALPHA}->${alpha_lc_panel_name}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING} 
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_6X_LC_PATCHING}
        \    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}/${port_list}[${i}]
        ...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        \    Close Trace Window
    
SM-29556-04_Verify that the correct routing for branch connection is shown on Trace window in circuit: LC MNE -> cabled (6xLC-MPO12) to -> Panel 01 -> patched (MPO12-MPO12) to -> Panel 02 -> cabled (MPO12-6xLC) to -> LC Switch
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29556_04
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Reload Page 
    [Teardown]    Run Keyword    Delete Building    name=${building_name}  
    
    ${tc_wo_name}    Set Variable    WO_SM29556_04
    
    # 1. Launch and log into SM Web
	# 2.In SM, add objects:
    # _MPO Panel 01
    # _MPO Panel 02
    # _Switch 01 with some LC ports
    # _Switch 02 with some LC ports
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME_1}    portType=${MPO}    quantity=1    
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME_2}    portType=${MPO}    quantity=1
    
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_1}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}    name=${01}    portType=${LC}    quantity=6
        
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_2}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${01}    portType=${LC}    quantity=6
    
	# 3. Open Cabling window, cable from:
    # _Panel 01/01 (MPO12-6xLC) to Switch 01/01->06
    # _Panel 02/01 (MPO12-6xLC) to Switch 02/01->06
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}    ${MPO12}    ${Mpo12_6xLC}
    ...    mpoBranches=${A1-2},${A3-4},${A5-6},${A7-8},${A9-10},${A11-12}    portsTo=${01},${02},${03},${04},${05},${06}
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    ${MPO12}    ${Mpo12_6xLC}
    ...    mpoBranches=${A1-2},${A3-4},${A5-6},${A7-8},${A9-10},${A11-12}    portsTo=${01},${02},${03},${04},${05},${06}
    Close Cabling Window  
    
	# 4. Open Patching window, patch from:
    # _Panel 01/01 (MPO12-MPO12) to Panel 02/01
    # _Do not Complete this job
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}
    ...    portsFrom=${01}    portsTo=${01}    mpoTab=${MPO12}    mpoType=${Mpo12_Mpo12}    createWo=${TRUE}    clickNext=${TRUE}
    Create Work Order    ${tc_wo_name}
    
    # 5. Trace ports in circuit and observe 
    # Trace window should be shown as below:
    # + Current View:
    # _Panel 01, Switch 01: Panel 01/01 [A1] -> cable (MPO12-6xLC) to -> Switch 02/01 [A1-2]-06 [A11-12]
    # _Panel 02, Switch 02: Panel 02/01 [A1] -> cabled (MPO12-6xLC) to -> Switch 02/01 [A1-2] ->06 [A11-12]
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01}
    
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}       
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
    ${pair_list}	Create List    ${A1-2}    ${A3-4}    ${A5-6}    ${A7-8}    ${A9-10}    ${A11-12}
    
    :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]    
        \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}/${port_list}[${i}]
        ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_CABLING} 
        \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]    
        \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${port_list}[${i}]
        ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list}[${i}]->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_CABLING} 
        \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    # + Scheduled View:
    # _Panel 01, Panel 02, Switch 01, Switch 02: Switch 01/01 [A1-2]- 06 [A11-12] -> cabled (6xLC-MPO12) to -> Panel 01 [ /A1] -> patched (MPO12-MPO12) to -> Panel 02 [ /A1]-> cabled (MPO12-6xLC) to -> LC Switch 06 [A11-12] - 01[A1-2]
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01}
    Select View Type On Trace    Scheduled
    
    ${port_list_rev}    Reverse List    ${port_list}      
    ${object_position_list_rev}    Reverse List    ${object_position_list}
    ${pair_list_rev}    Reverse List    ${pair_list}
      
    :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}/${port_list}[${i}]
        ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_CABLING} 
        \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_PATCHING}
        \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [ /${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_CABLING}
        \    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${object_position_list_rev}[${i}] [${pair_list_rev}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${port_list_rev}[${i}]
        ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_rev}[${i}]->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_ASSIGN_CABLING}
    Close Trace Window
    
    # 6. Complete Job at step 4
    Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue

    # 7. Trace port in circuit and observe
    # Trace window should be shown as below:
    # + Current View:
    # _Panel 01, Panel 02, Switch 01, Switch 02: Switch 01/01 [A1-2]- 06 [A11-12] -> cabled (6xLC-MPO12) to -> Panel 01 [ /A1] -> patched (MPO12-MPO12) to -> Panel 02 [ /A1]-> cabled (MPO12-6xLC) to -> LC Switch 06 [A11-12] - 01[A1-2]
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}/${port_list}[${i}]
        ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_CABLING} 
        \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_PATCHING}
        \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [ /${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_CABLING}
        \    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${object_position_list_rev}[${i}] [${pair_list_rev}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${port_list_rev}[${i}]
        ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_rev}[${i}]->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_ASSIGN_CABLING}
    Close Trace Window
    
SM-29556-06_Verify that the correct routing for branch connection is shown on Trace window in circuit: Beta Panel -> cabled to -> MPO Generic Panel -> patched (MPO12-6xLC) to -> Server 01
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29556_06
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Reload Page 
    [Teardown]    Run Keyword    Delete Building    name=${building_name}
    
    ${tc_wo_name}    Set Variable    WO_SM29556_06
    ${beta_lc_panel_name}    Set Variable    Beta LC Panel 01
    
    # 1. Launch and log into SM Web
	# 2.In SM, add objects:
    # _Beta LC Panel 01
    # _MPO Generic Panel 02
    # _LC Server 03
    ${multi_module_list}    Set Variable    Module 1A,${TRUE},LC 12 Port,Beta;Module 1B,${FALSE};Module 1C,${FALSE};Module 1D,${FALSE}
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 Fiber Shelf (1U)}    ${beta_lc_panel_name}    ${multi_module_list}    
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME_2}    portType=${MPO}    quantity=1
    Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SERVER_NAME_1}
    Add Device In Rack Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}    01    portType=${LC}    quantity=6     

	# 3. Open Cabling window, cable from:
    # _Panel 01/01 (MPO12-MPO12) to Panel 02/01
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${beta_lc_panel_name}
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${beta_lc_panel_name}/${MODULE_1A_BETA}/${MPO 01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${MPO12}    ${Mpo12_Mpo12}    portsTo=${01}
    Close Cabling Window  
    
	# 4. Open Patching window, patch from:
    # _Panel 02/01 (MPO12-6xLC) to Server 01/01->06
    # Do not Complete this job
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${01}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC}    mpoBranches=${A1-2},${A3-4},${A5-6},${A7-8},${A9-10},${A11-12}    createWo=${TRUE}    clickNext=${TRUE}
    Create Work Order    ${tc_wo_name}
    
    # 5. Trace window should be shown as below:
    # + Current View:
    # _Panel 01, Panel 02: Panel 01/01->06 (MPO1) -> cable to -> Panel 02/01
    # _Server 01: Server 01/01->06
    # + Scheduled View:
    # _Panel 01, Panel 02, Server 01: Server 01/01 [A1-2] - 06 [A11-12] -> patched (6xLC-MPO12) to -> Panel 02/01 [A1] -> cabled to -> Panel 01/01 (MPO1)- 06(MPO1)
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}       
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
    ${pair_list}	Create List    ${A1-2}    ${A3-4}    ${A5-6}    ${A7-8}    ${A9-10}    ${A11-12}
    
    :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${beta_lc_panel_name}/${MODULE_1A_BETA}    ${port_list}[${i}]    
        \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${object_position_list}[${i}] (${MPO1})    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${beta_lc_panel_name}/${MODULE_1A_BETA}/${port_list}[${i}]
        ...    objectType=${Trace 360 instapatch Fiber Shelf}    informationDevice=${port_list}[${i}]->${MODULE_1A_BETA}->${beta_lc_panel_name}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}   
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        \    Select View Type On Trace    Scheduled
        \    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${object_position_list}[${i}] (${MPO1})     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${beta_lc_panel_name}/${MODULE_1A_BETA}/${port_list}[${i}]
        ...    objectType=${Trace 360 instapatch Fiber Shelf}    informationDevice=${port_list}[${i}]->${MODULE_1A_BETA}->${beta_lc_panel_name}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING} 
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_6X_LC_PATCHING}
        \    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}/${port_list}[${i}]
        ...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        \    Close Trace Window

    # 6. Complete Job at step 4
    Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue

    # # 7. Trace window should be shown as below:
    # # + Current View:
    # # _Panel 01, Panel 02, Server 01: Server 01/01 [A1-2] -> 06 [A11-12] -> patched (6xLC-MPO12) to -> Panel 02/01 [A1] -> cabled to -> Panel 01/01->06(MPO1)
    :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}    ${port_list}[${i}]
        \    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${object_position_list}[${i}] (${MPO1})     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${beta_lc_panel_name}/${MODULE_1A_BETA}/${port_list}[${i}]
        ...    objectType=${Trace 360 instapatch Fiber Shelf}    informationDevice=${port_list}[${i}]->${MODULE_1A_BETA}->${beta_lc_panel_name}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING} 
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_6X_LC_PATCHING}
        \    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}/${port_list}[${i}]
        ...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        \    Close Trace Window