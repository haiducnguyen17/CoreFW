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

Suite Setup    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}

Suite Teardown    Close Browser

Default Tags    Connectivity
Force Tags    SM-30080

*** Variables ***
${FLOOR_NAME}    Floor 01
${ROOM_NAME}    Room 01
${RACK_NAME}    Rack 001
${POSITION_RACK_NAME}    1:1 Rack 001
${PANEL_NAME_1}    Panel 01
${PANEL_NAME_2}    Panel 02
${PANEL_NAME_3}    Panel 03
${PANEL_NAME_4}    Panel 04
${SWITCH_NAME_1}    Switch 01
${SWITCH_NAME_2}    Switch 02
${SERVER_NAME_1}    Server 01    

*** Test Cases ***
SM-30080-01-Verify the "No Path" message and icon is displayed on Trace window when user create cabling MPO12-New_6xLC from HSM Port (DM08) to LC Panel Port
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM30080_03
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Reload Page 
    [Teardown]    Run Keyword    Delete Building    name=${building_name}
 
    [Tags]    Sanity

	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _HSM Panel 01 (DM08)
	# _LC Panel 02
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_1}    ${Module 1A},True,${LC 12 Port},${DM08}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME_2}    portType=${LC}    

	# 4. Cable from Panel 01// MPO 01 (MPO12-New_6xLC)/ 1-1 -> 6-6 to Panel 02// 01-06
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A} (${DM08})    ${MPO1-01}
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A} (${DM08})/${MPO} ${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${MPO12}    ${Mpo12_6xLC_EB}    portsTo=${01},${02},${03},${04},${05},${06}
    Close Cabling Window
    
	# 5. Open trace for Panel 02/05,06 and observe the result    
	Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${05}    
	Check Total Trace On Site Manager    2
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=5 [ /5-5]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${05}
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${05}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}    
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=(${MPO1})    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A}
    ...    objectType=${DM08}    informationDevice=${No Path}->${Module 1A}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
	Close Trace Window

	Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${06}    
	Check Total Trace On Site Manager    2
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=6 [ /6-6]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${06}
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${06}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}    
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=(${MPO1})    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A}
    ...    objectType=${DM08}    informationDevice=${No Path}->${Module 1A}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}   
    Close Trace Window
    
SM-30080-02-Verify the The "No Path" message and icon is displayed on Trace window for circuit: LC Switch -> patched to -> DM08 -> cabled -> MPO12 Panel -> patched (MPO12-6xLC EB) to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM30080_02
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Reload Page 
    [Teardown]    Run Keyword    Delete Building    name=${building_name} 
  
	${tc_wo_name}    Set Variable    WO_SM30080_02
    
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add: 
	# _LC Switch 01
	# _Panel 01 (DM08)
	# _MPO Panel 02
	# _LC Server 01
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_1}    ${Module 1A},True,${LC 12 Port},${DM08}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME_2}    portType=${MPO}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_1}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}    name=${01}    portType=${LC}    quantity=4
    Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SERVER_NAME_1}
    Add Device In Rack Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}    ${01}    portType=${LC}    quantity=6        
    	
    # # 4. Cable from Panel 01// MPO 01 (MPO12-MPO12) to Panel 02// 01
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A} (${DM08})    ${MPO1-01}
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A} (${DM08})/${MPO} ${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${MPO12}    ${Mpo12_Mpo12}    portsTo=${01}
    Close Cabling Window
    
	# 5. Create Add Patch job and DO NOT complete it from: 
	# _Panel 01// MPO1-01 -> 04 to Switch 01// 01-04
	# _Panel 02// 01 (MPO12-New_6xLC)/ 1-1 to 6-6 to Server 01// 01-06 
	Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A} (${DM08})    ${MPO1-01}        
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A} (${DM08})    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}
    ...    portsFrom=${MPO1-01}    portsTo=${01}   createWo=yes    clickNext=no
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A} (${DM08})    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}
    ...    portsFrom=${MPO1-02}    portsTo=${02}    createWo=yes    clickNext=no
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A} (${DM08})    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}
    ...    portsFrom=${MPO1-03}    portsTo=${03}    createWo=yes    clickNext=no
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A} (${DM08})    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}
    ...    portsFrom=${MPO1-04}    portsTo=${04}    createWo=yes    clickNext=no
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    createWo=yes    clickNext=yes
    Create Work Order    ${tc_wo_name} 
    
	# 6. Open trace for Panel 02/01 and select view type is Schedule
	# 7. Select Pair 05, 06 on Trace window and observe the result
	Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${01}
	Select View Type On Trace    Scheduled
	Select View Trace Tab On Site Manager    ${Pair 5}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=(${MPO1})    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A} (${DM08})
    ...    objectType=${DM08}    informationDevice=${No Path}->${Module 1A} (${DM08})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=5 [${Pair 5}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}/${05}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${05}->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
	Select View Trace Tab On Site Manager    ${Pair 6}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=(${MPO1})    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A} (${DM08})
    ...    objectType=${DM08}    informationDevice=${No Path}->${Module 1A} (${DM08})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=6 [${Pair 6}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}/${06}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${06}->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
  	Close Trace Window
    	
	# 8. Complete work oder
	Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue
	
	# 9. Open trace for Panel 02/01 
	Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${01}    

	# 10. Select Pair 05, 06 on Trace window and observe the result
	Select View Trace Tab On Site Manager    ${Pair 5}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=(${MPO1})    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A} (${DM08})
    ...    objectType=${DM08}    informationDevice=${No Path}->${Module 1A} (${DM08})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=5 [${Pair 5}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}/${05}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${05}->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
	Select View Trace Tab On Site Manager    ${Pair 6}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=(${MPO1})    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${Module 1A} (${DM08})
    ...    objectType=${DM08}    informationDevice=${No Path}->${Module 1A} (${DM08})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=6 [${Pair 6}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME_1}/${06}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${06}->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
  	Close Trace Window
    
SM-30080-03-Verify the The "No Path" message and icon is displayed on Trace window for circuit: LC Panel - cabled to (MPO12-6xLC EB) -> MPO12 Panel - patched to -> MPO12 Panel - cabled to -> DM 08
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM30080_03
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Reload Page 
    [Teardown]    Run Keyword    Delete Building    name=${building_name}
 
	${tc_wo_name}    Set Variable    WO_SM30080_03
	${module_1a_passthrough}    Set Variable    ..le 1A (${Pass-Through})
    
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add: 
	# _MPO Panel 01, 02
	# _HSM LC Panel 03
	# _Panel 04 (DM08)
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME_1}    portType=${MPO}    quantity=2
    Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_3}    ${Module 1A},True,${LC 6 Port},,
    Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 Fiber Shelf (2U)}    ${PANEL_NAME_4}    ${Module 1A},True,${LC 12 Port},${DM08}

    # 4. Cable from:
	# _Panel 01// 01 (MPO12-MPO12) to Panel 04// MPO 01
	# _Panel 02// 01 (MPO12-6xLC EB) to Panel 03// 01
	Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01}
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_4}/${Module 1A} (${DM08})  
    ...    portsTo=${MPO} ${01}
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_3}/${Module 1A} (${Pass-Through})
    ...    ${MPO12}    ${Mpo12_6xLC_EB}    portsTo=${01},${02},${03},${04},${05},${06}
    Close Cabling Window
    
	# 5. Create Add Patch job and DO NOT complete it from: 
	# _Panel 01// 01 to Panel 02// 01
	Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}
    ...    portsFrom=${01}    portsTo=${01}   createWo=yes    clickNext=yes
    Create Work Order    ${tc_wo_name}
    
    # 6. Open trace for Panel 02/01 and select view type is Schedule
	# 7. Select Pair 05, 06 on Trace window and observe the result
	Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${01}
	Select View Type On Trace    Scheduled
	Select View Trace Tab On Site Manager    ${Pair 5}
	
	Check Total Trace On Site Manager    4
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=5 [ /${Pair 5}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_3}/${Module 1A} (${Pass-Through})/${05}
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${05}->${module_1a_passthrough}->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}    
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [ /${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=(${MPO1})    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_4}/${Module 1A} (${DM08})
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${No Path}->${Module 1A} (${DM08})->${PANEL_NAME_4}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
	Select View Trace Tab On Site Manager    ${Pair 6}
    Check Total Trace On Site Manager    4
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=6 [ /${Pair 6}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_3}/${Module 1A} (${Pass-Through})/${06}
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${06}->${module_1a_passthrough}->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}    
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [ /${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=(${MPO1})    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_4}/${Module 1A} (${DM08})
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${No Path}->${Module 1A} (${DM08})->${PANEL_NAME_4}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}  	
    
	# 8. Close Trace window
    Close Trace Window
    
	# 9. Complete work oder
    Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue
			
	# 10. Open trace for Panel 02/01 
	Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    ${01}
	
	# 11. Select Pair 05, 06 on Trace window and observe the result
	Select View Trace Tab On Site Manager    ${Pair 5}
	Check Total Trace On Site Manager    4
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=5 [ /${Pair 5}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_3}/${Module 1A} (${Pass-Through})/${05}
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${05}->${module_1a_passthrough}->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}    
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [ /${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=(${MPO1})    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_4}/${Module 1A} (${DM08})
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${No Path}->${Module 1A} (${DM08})->${PANEL_NAME_4}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
	Select View Trace Tab On Site Manager    ${Pair 6}
    Check Total Trace On Site Manager    4
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=6 [ /${Pair 6}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_3}/${Module 1A} (${Pass-Through})/${06}
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${06}->${module_1a_passthrough}->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}    
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [ /${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=(${MPO1})    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_4}/${Module 1A} (${DM08})
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${No Path}->${Module 1A} (${DM08})->${PANEL_NAME_4}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}  	
	Close Trace Window
	
SM-30080-04-Verify the The "No Path" message and icon is displayed on Trace window for circuit: MPO12 Switch -> patched to -> MPO12 -> cabled (MPO12-6xLC EB) to -> LC Switch
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM30080_04
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Reload Page 
    [Teardown]    Run Keyword    Delete Building    name=${building_name}

	${tc_wo_name}    Set Variable    WO_SM30080_04
	
	# 1Delete Building    name=${building_name} _MPO12 Switch 01 (4 channels)
	# _MPO Panel 01
	# _LC Switch 02
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME_1}    portType=${MPO}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_1}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}    name=${01}    portType=${MPO12}    portConfiguration=${4x10G}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_2}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${01}    portType=${LC}    quantity=6
    
    # 4. Cable from Panel 01// 01 (MPO12-6xLC EB)/ Pair 1 -> Pair 6 to Switch 02// 01-06
	Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01}
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}
    ...    ${MPO12}    ${Mpo12_6xLC_EB}    portsTo=${01},${02},${03},${04},${05},${06}
    Close Cabling Window       

    # 5. Create the Add Patch job and DO NOT complete the job from Panel 01// 01 (MPO12-MPO12) to Switch 01// 01
	Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}
    ...    portsFrom=${01}    portsTo=${01}   createWo=yes    clickNext=yes    
    Create Work Order    ${tc_wo_name}
    
	# 6. Open trace for Panel 01/01 and select view type is Schedule
	# 7. Select Pair 05, 06 on Trace window and observe the result
	Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01}
	Select View Type On Trace    Scheduled
	Select View Trace Tab On Site Manager    ${Pair 5}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=5 [${Pair 5}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${05}
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${05}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [ /${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}/${01}
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${No Path}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
	Select View Trace Tab On Site Manager    ${Pair 6}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=6 [${Pair 6}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${06}
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${06}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [ /${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}/${01}
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${No Path}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	# 8. Close Trace window
	Close Trace Window
	
	# 9. Complete work oder
	Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue
	
	# 10. Open trace for Panel 01/01 
	# 11. Select Pair 05, 06 on Trace window and observe the result    
	Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}    ${01}
	Select View Trace Tab On Site Manager    ${Pair 5}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=5 [${Pair 5}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${05}
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${05}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [ /${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}/${01}
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${No Path}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
	Select View Trace Tab On Site Manager    ${Pair 6}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=6 [${Pair 6}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${06}
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${06}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [ /${A1}]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_1}/${01}
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${No Path}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window

