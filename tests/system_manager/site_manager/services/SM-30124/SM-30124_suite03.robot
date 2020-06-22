*** Settings ***
Resource    ../../../../../resources/bug_report.robot
Resource    ../../../../../resources/constants.robot
Resource    ../../../../../resources/icons_constants.robot

Library   ../../../../../py_sources/logigear/setup.py 
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py        
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py       
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py   
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/work_order_queue/WorkOrderQueuePage${PLATFORM}.py     
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/services/change_service/ChangeServicePage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/services/provide_service/ProvideServicePage${PLATFORM}.py       
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/services/move_services/MoveServicesPage${PLATFORM}.py          
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/remove_circuit/RemoveCircuitPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/events/event_log/EventLogPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/front_to_back_cabling/FrontToBackCablingPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}    

Force Tags    SM-30124
Default Tags    Services

*** Variables ***
${FLOOR_NAME_1}    Floor 01
${ROOM_NAME_1}    Room 01
${ROOM_NAME_2}    Room 02
${RACK_NAME_1}    Rack 001
${RACK_NAME_2}    Rack 002
${SWITCH_NAME_1}    Switch 01
${SWITCH_NAME_2}    Switch 02
${SERVER_NAME_1}    Server 01
${PANEL_NAME_1}    Panel 01
${PANEL_NAME_2}    Panel 02
${PANEL_NAME_3}    Panel 03
${PANEL_NAME_4}    Panel 04
${PANEL_NAME_5}    Panel 05
${PANEL_NAME_6}    Panel 06
${PANEL_NAME_7}    Panel 07
${PANEL_NAME_8}    Panel 08
${DEVICE_NAME_1}    Device 01
${FACEPLATE_1}    Faceplate 01
${FACEPLATE_2}    Faceplate 02

*** Test Cases ***
SM-30124_01-Verify that the user can change sevice/remove circuit for 6xLC EB with circuit: LC Switch -> cabled 6xLC to -> MPO Panel 01 -> patched 6xLC to -> LC Panel 02
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-30124-01
    ...    AND    Delete Building     ${building_name}
    ...    AND    Add New Building    ${building_name}    
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}   

    [Teardown]    Run Keywords    Delete Building     ${building_name}
    ...    AND    Close Browser
    
    [Tags]    Sanity

    ${position_rack_name_1}    Set Variable    1:1 Rack 001
    ${position_rack_name_2}    Set Variable    1:2 Rack 002
    ${tree_node_panel_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_1}
    ${tree_node_panel_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_2}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_2}/${SWITCH_NAME_1}
    ${tree_node_server_01}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${SERVER_NAME_1}
    ${wo_name}    Set Variable    SM-30124_01
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${pair_list}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${in_use_5/6}    Set Variable    In Use - 5/6
    
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${building_name}
    
    # 3. Add to 1:1 Rack 001:
	# _MPO Generic Panel 01
	# _LC Generic Panel 02
	# _LC Server 01
	# 4. Add to 1:2 Rack 002:
	# _LC Switch 01
	# 5. Set:
	# _Voice service for Switch 01// 01 directly
	# _Data service for Switch 01// 02 directly
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME_1}    roomName=${ROOM_NAME_1}    rackName=${RACK_NAME_1}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}    ${RACK_NAME_2}    position=2
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}
    ...    ${PANEL_NAME_1}    portType=${MPO}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}
    ...    ${PANEL_NAME_2}    portType=${LC}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_2}    ${SWITCH_NAME_1}
    Add Network Equipment Port    ${tree_node_switch_1}    name=${01}   portType=${LC}    listChannel=${01}    listServiceType=${Voice}
    Add Network Equipment Port    ${tree_node_switch_1}    name=${02}   portType=${LC}    listChannel=${02}    listServiceType=${Data}
    Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}    ${SERVER_NAME_1}    
	Add Device In Rack Port    ${tree_node_server_01}    name=${01}    portType=${LC}    quantity=6
	# 6. Cable 6xLC EB from Panel 01/01 to Switch 01/01
	Open Cabling Window    ${tree_node_panel_1}    ${01}
	Create Cabling    cableFrom=${tree_node_panel_1}/${01}    cableTo=${tree_node_switch_1}    mpoTab=${MPO12}    
	...    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1}    
	...    portsTo=${01}
	Close Cabling Window
	
	# 7. Patch 6xLC EB from Panel 01/01 to Panel 02/01-06 and complete this job
	Open Patching Window    ${tree_node_panel_1}    ${01}
	Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_panel_2}    portsFrom=${01}    
	...    portsTo=${01},${02},${03},${04},${05},${06}    mpoType=${Mpo12_6xLC_EB}    
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    createWo=${False}
	
	# 8. Select Panel 02/01 and change service
	# 9. Select Data service in Change Service window and press on Connect button
	# 10. At Search Service window, Service Found text shows
	# 11. Click on Show link and observe
	# 12. Create "Change Service" job
    Open Services Window    Change Service    ${tree_node_panel_2}     ${01}
    Change Service    service=${Data}
    Create Work Order    woName=${wo_name}    scheduling=Immediate    clickNext=${True}
    Wait For Work Order Icon On Content Table    ${01}
    
	# 13. Select Panel 02/01, Switch/01-02, Panel 01/01 and observe port
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    1
	Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    1
	Click Tree Node On Site Manager    ${tree_node_switch_1}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    1
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${02},${In Use - Pending}    2

	# 14. Complete this job at step 12 and observe port status
	Open Work Order Queue Window
	Complete Work Order    ${wo_name}
	Close Work Order Queue
	
	# 15. Trace Panel 01/01 and observe the circuit
	# 16. Trace Panel 02/01 and observe the circuit
	Open Trace Window    ${tree_node_panel_1}    ${01}    
	Select View Trace Tab On Site Manager    ${Pair 1}
	Check Total Trace On Site Manager    3
	Check Trace Object On Site Manager    indexObject=1    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Voice}    
	...    objectType=${TRACE_SERVICE}    connectionType=${TRACE_ASSIGN}
	...    informationDevice=${TRACE_OBJECT_SERVICE}->${Voice}->${TRACE_VLAN}->${TRACE_CONFIG}
	Check Trace Object On Site Manager    indexObject=2    objectPosition=1 [${Pair 1}]
	...    objectPath=${tree_node_switch_1}/01    objectType=${TRACE_SWITCH_IMAGE}    portIcon=${PortNEFDServiceCabled}    
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${SWITCH_NAME_1}->${position_rack_name_2}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=1 [${A1}/${A1}]
	...    objectPath=${tree_node_panel_1}/01    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    mpoType=12    portIcon=${PortMPOServiceCabledInUse}    
	...    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Close Trace Window
	
    :FOR    ${i}     IN RANGE    1    len(${port_list})
    \    Open Trace Window    ${tree_node_panel_2}    ${port_list}[${i}]    
    \    ${i_str}    Convert To String    ${i+1}
    \    Check Total Trace On Site Manager    2
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str} [${pair_list}[${i}]]
	...    objectPath=${tree_node_panel_2}/${port_list}[${i}]    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    portIcon=${PortFDUncabledInUse}       
	...    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
	...    informationDevice=${port_list}[${i}]->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=1 [${A1}/${A1}]
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    mpoType=12    portIcon=${PortMPOServiceCabledInUse}    
	...    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	\	Close Trace Window
   
	# 17. Patch 6xLC EB from Panel 01/01 to Server 01/01 and complete this job
	Open Patching Window    ${tree_node_panel_1}    ${01}
	Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_server_01}    portsFrom=${01}    
	...    portsTo=${01}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1}    createWo=${False}   
	
	# 18. Select Panel 01/01 and remove circuit
	# 19. Select "Select patch connections to retain" option
	# 20. Uncheck patch connection from pair 2-6
	# 21. Create Remove Circuit job
	Open Remove Circuit Window    ${tree_node_panel_1}    ${01}
	Remove Circuit    removeAllPatches=${False}    createWo=${True}    clickNext=${False}
	:FOR    ${i}     IN RANGE    1    len(${pair_list})-1
	\    Select View Trace Tab On Remove Circuit Window    ${pair_list}[${i}]
	\    Uncheck Remove Patching On Remove Circuit Window    1    clickNext=${False}
	Select View Trace Tab On Remove Circuit Window    ${Pair 6}
	Uncheck Remove Patching On Remove Circuit Window    1    clickNext=${True}
	Create Work Order    ${wo_name}
	Wait For Work Order Icon On Content Table    ${01}
	    
	# 22. Complete Job and Trace Server 01/01
	Open Work Order Queue Window
	Complete Work Order    ${wo_name}
	Close Work Order Queue
	Open Trace Window    ${tree_node_server_01}    ${01}    
	Check Total Trace On Site Manager    1
	Check Trace Object On Site Manager    indexObject=1    objectPosition=1   
	...    objectPath=${tree_node_server_01}/${01}    objectType=${TRACE_SERVER_FIBER_IMAGE}    portIcon=${PortFDUncabledAvailable}    
	...    informationDevice=${01}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Close Trace Window
	
	# 23. Observe port status on Content pane
    Click Tree Node On Site Manager    ${tree_node_server_01}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
    Click Tree Node On Site Manager    ${tree_node_panel_1}
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${in_use_5/6}    1

# Invalid TC due to design changed
# SM-30124_02-Verify that the user can move person/remove cicuit for 6xLC EB: LC Switch -> cabled -> LC Panel 01 -> patch 4xLC -> MPO Panel 02 -> cabled -> MPO Panel 03 -> patch 6xLC -> LC Panel 4 -> cable -> outlet -> connect -> device -> assign -> person
    # [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-30124-02
    # ...    AND    Delete Building     ${building_name}
    # ...    AND    Add New Building    ${building_name}    
    # ...    AND    Open SM Login Page
    # ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}    

    # [Teardown]    Run Keywords    Delete Building     ${building_name}
    # ...    AND    Close Browser
    
    # ${position_rack_name_1}    Set Variable    1:1 Rack 001
    # ${position_rack_name_2}    Set Variable    1:1 Rack 002
    # ${tree_node_panel_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_1}
    # ${tree_node_panel_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_2}
    # ${tree_node_panel_3}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_3}
    # ${tree_node_panel_4}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_4}    
    # ${tree_node_panel_5}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}/${PANEL_NAME_5}
    # ${tree_node_panel_6}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}/${PANEL_NAME_6}
    # ${tree_node_panel_7}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}/${PANEL_NAME_7}
    # ${tree_node_panel_8}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}/${PANEL_NAME_8}    
    # ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${SWITCH_NAME_1}
    # ${tree_node_switch_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}/${SWITCH_NAME_2}
    # ${tree_node_faceplate_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${FACEPLATE_1}
    # ${tree_node_faceplate_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${FACEPLATE_2}
    # ${tree_node_room_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}
    # ${tree_node_room_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}
    # ${wo_name}    Set Variable    SM-30124_02
    # ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    # ${pair_list}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    # ${person_first_name}    Set Variable    Test
    # ${person_last_name}    Set Variable    Person
    # ${person_name}    Set Variable    ${person_last_name}, ${person_first_name}
    
    # Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${building_name}    
    # # 1.Launch and log into SM
    # # 2. Go to Site Manager 
    # # 3. Add Room 01:
	# # _LC Faceplate 01
	# # _Device 01
	# # _Person (assing this person to Device 01)
	# # 4. Add to Room 02:
	# # _LC Faceplate 01
	# # 5. Add to Room 01/Rack 001:
	# # _LC Switch 01 (set Voice sevice for port 01)
	# # _LC Panel 01
	# # _MPO Panel 02
	# # _MPO Panel 03
	# # _LC Panel 04
	# # 6. Add to Room 02/Rack 001:
	# # _LC Switch 01 (set Voice sevice for port 01)
	# # _LC Panel 01
	# # _MPO Panel 02
	# # _MPO Panel 03
	# # _LC Panel 04
	# Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME_1}    roomName=${ROOM_NAME_1}    rackName=${RACK_NAME_1}
	# Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}    ${ROOM_NAME_2}    
	# Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}    ${RACK_NAME_2}
	# Add Person    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}    ${person_first_name}    ${person_last_name}
	# Add Device    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}    ${Computer}    ${DEVICE_NAME_1}    ${person_name}    
	# Add Faceplate    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}    ${FACEPLATE_1}    ${LC}
	# Add Faceplate    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}    ${FACEPLATE_2}    ${LC}
	# Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}    ${SWITCH_NAME_1}    
	# Add Network Equipment Port    ${tree_node_switch_1}    ${01}       portType=${LC}    
	# ...    listChannel=${01}    listServiceType=${Data} 
	# Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}    ${SWITCH_NAME_2}    
	# Add Network Equipment Port    ${tree_node_switch_2}    ${01}       portType=${LC}    
	# ...    listChannel=${01}    listServiceType=${Data}
	# Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}    
	# ...    name=${PANEL_NAME_1}    portType=${LC}
    # Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}    
	# ...    name=${PANEL_NAME_2}    portType=${MPO}    quantity=2
	# Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}    
	# ...    name=${PANEL_NAME_4}    portType=${LC}
    # Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}    
	# ...    name=${PANEL_NAME_5}    portType=${LC}
    # Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}    
	# ...    name=${PANEL_NAME_6}    portType=${MPO}    quantity=2
	# Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}    
	# ...    name=${PANEL_NAME_8}    portType=${LC}
	
	# # 7. Create cicuit in Room 01 and Room 02:
	# # _Cable LC-LC from Panel 01/01 to Switch 01/01
	# # _Patch 6xLC from Panel 02/01 to Panel 01/01-06 and complete job
	# # _Cable MPO12-MPO12 from Panel 02/01 to Panel 03/01
	# # _Cable from Panel 04/01-06 to Faceplate 01/01-06
	# # 8. Patch 6xLC from Panel 03/01 to Panel 04/01-06 in Room 01 and complete job
	# Open Cabling Window    ${tree_node_panel_1}    ${01}
	# #cab Room 01
	# Create Cabling    cableFrom=${tree_node_panel_1}/01    cableTo=${tree_node_switch_1}    portsTo=${01}
	# Create Cabling    cableFrom=${tree_node_panel_2}/01    cableTo=${tree_node_panel_3}    portsTo=${01}
	# Create Cabling    cableFrom=${tree_node_panel_4}/01    cableTo=${tree_node_faceplate_1}    portsTo=${01}
	# #Cab Room 02
	# Create Cabling    cableFrom=${tree_node_panel_5}/01    cableTo=${tree_node_switch_2}    portsTo=${01}
	# Create Cabling    cableFrom=${tree_node_panel_6}/01    cableTo=${tree_node_panel_7}    portsTo=${01}
	# Create Cabling    cableFrom=${tree_node_panel_8}/01    cableTo=${tree_node_faceplate_2}    portsTo=${01}
	# Close Cabling Window
	
	# # Patch Room 01
	# Open Patching Window    ${tree_node_panel_2}    ${01}
	# Create Patching    patchFrom=${tree_node_panel_2}    patchTo=${tree_node_panel_1}    
	# ...    portsFrom=${01}    portsTo=${01},${02},${03},${04}
	# ...    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    
	# ...    mpoBranches=${1-1},${2-2},${3-3},${4-4}
	# ...    clickNext=${False}
	# Create Patching    patchFrom=${tree_node_panel_3}    patchTo=${tree_node_panel_4}    
	# ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}
	# ...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    
	# ...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
	# ...    clickNext=${False}
	# #Patch Room 02
	# Create Patching    patchFrom=${tree_node_panel_6}    patchTo=${tree_node_panel_5}    
	# ...    portsFrom=${01}    portsTo=${01},${02},${03},${04}
	# ...    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    
	# ...    mpoBranches=${1-1},${2-2},${3-3},${4-4}
	# ...    createWo=${False}    clickNext=${True}
    
	# # 9. Connect Faceplate 01/01 to Device 01
	# Open Patching Window    treeNode=${tree_node_faceplate_1}    objectName=${01}
	# Create Patching    patchFrom=${tree_node_faceplate_1}    patchTo=${tree_node_room_1}
	# ...    portsFrom=${01}    portsTo=${DEVICE_NAME_1}
	# ...    clickNext=${True}
	
	# # 10. Select Room 01/Device 01 and move service
	# Open Services Window    Move Services    ${tree_node_room_1}    ${DEVICE_NAME_1}
	
	# # 11. Select Room 02 in Move To pane and go next screen
	# # 12. In Move Service for Device 01 window, select Faceplate 01/01 in Room 02 and search service
	# # 13. Observe the result
	# Move Services    moveTo=${tree_node_room_2}    
	# ...    moveServiceFrom=${tree_node_faceplate_1}/${01}    moveServiceTo=${tree_node_faceplate_2}/${01}
	
	# # 14. Create "Move Service" job
	# Create Work Order    ${wo_name}
	# Wait For Work Order Icon On Content Table    ${DEVICE_NAME_1}
	
	# # 15. Clear Person Moved priority event and complete job
	# Open Events Window
	# Clear Event On Event Log    All    
	# Close Event Log
	# Open Work Order Queue Window
    # Complete Work Order    ${wo_name}
    # Close Work Order Queue   
    
	# # 16. Trace Panel 02/01 in Room 01 and observe the circuit
	# Open Trace Window    ${tree_node_panel_2}    ${01}
	# Select View Trace Tab On Site Manager    ${1-1}
	# Check Total Trace On Site Manager    2
	# Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [${A1}]	
    # ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    # ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_LC_4X_MPO12_PATCHING}
    # ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
    # Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]	
    # ...    objectPath=${tree_node_panel_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    # ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    # ...    informationDevice=${01}->${PANEL_NAME_3}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
    # Check Trace Object On Site Manager    indexObject=3    	connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    
  	# Select View Trace Tab On Site Manager    ${2-2}
  	# Check Total Trace On Site Manager    4
  	# Check Trace Object On Site Manager    indexObject=1    objectPosition=2 [${2-2}]	
    # ...    objectPath=${tree_node_panel_1}/${02}    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    
    # ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_LC_4X_MPO12_PATCHING}
    # ...    informationDevice=${02}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	# Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]	
    # ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    # ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    # ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
    # Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]	
    # ...    objectPath=${tree_node_panel_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    # ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    # ...    informationDevice=${01}->${PANEL_NAME_3}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
    # Check Trace Object On Site Manager    indexObject=4    objectPosition=2 [${pair 2}]	
    # ...    objectPath=${tree_node_panel_4}/${02}    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    
    # ...    portIcon=${PortFDUncabledInUse}    
    # ...    informationDevice=${02}->${PANEL_NAME_4}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
    # Select View Trace Tab On Site Manager    ${3-3}
  	# Check Total Trace On Site Manager    4
  	# Check Trace Object On Site Manager    indexObject=1    objectPosition=3 [${3-3}]	
    # ...    objectPath=${tree_node_panel_1}/${03}    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    
    # ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_LC_4X_MPO12_PATCHING}
    # ...    informationDevice=${03}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	# Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]	
    # ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    # ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    # ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
    # Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]	
    # ...    objectPath=${tree_node_panel_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    # ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    # ...    informationDevice=${01}->${PANEL_NAME_3}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
    # Check Trace Object On Site Manager    indexObject=4    objectPosition=3 [${pair 3}]	
    # ...    objectPath=${tree_node_panel_4}/${03}    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    
    # ...    portIcon=${PortFDUncabledInUse}    
    # ...    informationDevice=${03}->${PANEL_NAME_4}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
    # Select View Trace Tab On Site Manager    ${4-4}
  	# Check Total Trace On Site Manager    4
  	# Check Trace Object On Site Manager    indexObject=1    objectPosition=4 [${4-4}]	
    # ...    objectPath=${tree_node_panel_1}/${04}    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    
    # ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_LC_4X_MPO12_PATCHING}
    # ...    informationDevice=${04}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	# Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]	
    # ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    # ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    # ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
    # Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]	
    # ...    objectPath=${tree_node_panel_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    # ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    # ...    informationDevice=${01}->${PANEL_NAME_3}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
    # Check Trace Object On Site Manager    indexObject=4    objectPosition=4 [${pair 4}]	
    # ...    objectPath=${tree_node_panel_4}/${04}    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    
    # ...    portIcon=${PortFDUncabledInUse}    
    # ...    informationDevice=${04}->${PANEL_NAME_4}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}

    # Report Bug    ${SM-30437}
  	# # 17. Trace Panel 03/01 in Room 01 and observe the circuit
	# # 18. Trace Panel 03/01 in Room 02 and observe the circuit
	# Open Trace Window    ${tree_node_panel_7}    ${01}    
	# Select View Trace Tab On Site Manager    ${1-1}
	# Check Total Trace On Site Manager    9
	# Check Trace Object On Site Manager    indexObject=1    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
	# ...    objectType=${TRACE_SERVICE}    connectionType=${TRACE_ASSIGN}    
	# ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}      
	# Check Trace Object On Site Manager    indexObject=2    objectPosition=1    
	# ...    objectPath=${tree_node_switch_2}/${01}    objectType=${TRACE_SWITCH_IMAGE}    
	# ...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING}    
	# ...    informationDevice=${01}->${SWITCH_NAME_2}->${position_rack_name_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=3    objectPosition=1 [${1-1}]    
	# ...    objectPath=${tree_node_panel_5}/${01}    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    
	# ...    portIcon=${PortNEFDServiceInUse}    connectionType=${TRACE_LC_4X_MPO12_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_5}->${position_rack_name_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]    
	# ...    objectPath=${tree_node_panel_6}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_6}->${position_rack_name_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=5    mpoType=12    objectPosition=1 [${A1}]   
	# ...    objectPath=${tree_node_panel_7}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_4LC_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_7}->${position_rack_name_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=6    objectPosition=1 [${1-1}]   
	# ...    objectPath=${tree_node_panel_8}/${01}    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    
	# ...    portIcon=${PortFDCabledInUse}    connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_8}->${position_rack_name_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=7    objectPosition=1   
	# ...    objectPath=${tree_node_faceplate_2}/${01}    objectType=${TRACE_LC_FACEPLATE_IMAGE}    
	# ...    portIcon=${PortFDCabledInUse}    connectionType=${TRACE_FIBER_PATCHING}
	# ...    informationDevice=${01}->${FACEPLATE_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=8   
	# ...    objectPath=${tree_node_room_2}/${DEVICE_NAME_1}    objectType=${TRACE_COMPUTER_IMAGE}
	# ...    informationDevice=${DEVICE_NAME_1}->${TRACE_OBJECT_IP}->${EMPTY}->${TRACE_OBJECT_MAC}
	# Close Trace Window
	
SM-30124_03_Verify that the user can remove circuit for 6xLC EB with circuit LC Switch -> patched 6xLC to -> MPO12 Panel -> cabled to -> MPO12 Panel -> patched 6xLC to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-30124-03
    ...    AND    Delete Building     ${building_name}
    ...    AND    Add New Building    ${building_name}    
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
 
    [Teardown]    Run Keywords    Delete Building     ${building_name}
    ...    AND    Close Browser
    
    ${position_rack_name_1}    Set Variable    1:1 Rack 001
    ${tree_node_panel_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_1}
    ${tree_node_panel_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_2}
    ${tree_node_server_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${SERVER_NAME_1}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${SWITCH_NAME_1}
    ${wo_patching}    Set Variable    add_patch
    ${wo_remove_circuit}    Set Variable    remove_circuit
    ${in_use_3/6}    Set Variable    In Use - 3/6
    ${in_use_2/6}    Set Variable    In Use - 2/6
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${pair_list}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${building_name}
    # 3. Add to Rack 001:
	# _LC Switch 01
	# _MPO Generic Panel 01
	# _MPO Generic Panel 02
	# _LC Server 01
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME_1}    roomName=${ROOM_NAME_1}    rackName=${RACK_NAME_1}
	Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}   
    ...    name=${PANEL_NAME_1}     portType=${MPO}    quantity=2
    Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}    ${SERVER_NAME_1}    
	Add Device In Rack Port    ${tree_node_server_1}    ${01}      portType=${LC}    quantity=6    
	Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}    ${SWITCH_NAME_1}    
	Add Network Equipment Port    ${tree_node_switch_1}    ${01}    portType=${LC}    quantity=6 
	
	# 4. Patch 6xLC EB from Panel 01/01 to Switch 01/01-06 and complete this job
	Open Patching Window    ${tree_node_panel_1}    ${01}
	Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_switch_1}    
	...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}
	...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
	...    createWo=${False}

	# 5. Cable MPO12-MPO12 from Panel 01/01 to Panel 02/01
	Open Cabling Window    ${tree_node_panel_1}    ${01}
	Create Cabling    cableFrom=${tree_node_panel_1}/${01}    cableTo=${tree_node_panel_2}    
	...    mpoTab=${MPO12}    mpoType=${Mpo12_2xMpo12}    portsTo=${01}
	Close Cabling Window
	
	# 6. Patch 6xLC EB from Panel 02/01 to Server 0/01-06 (not complete this job)
    Open Patching Window    ${tree_node_panel_2}    ${01}
	Create Patching    patchFrom=${tree_node_panel_2}    patchTo=${tree_node_server_1}    
	...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}
	...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    Create Work Order    ${wo_patching}
    Wait For Work Order Icon On Content Table    ${01}
	# 7. Select Panel 01/01 and remove circuit
	# 8. Select "Select patch connections to retain" option
	Open Remove Circuit Window    ${tree_node_panel_1}    ${01}
	Remove Circuit    removeAllPatches=${False}    createWo=${True}    clickNext=${False}
	
	# 9. Uncheck patch connection of pair 2, pair 4 and pair 6 to retain
	Select View Trace Tab On Remove Circuit Window    ${Pair 2}
	Uncheck Remove Patching On Remove Circuit Window    2    clickNext=${False}
	Select View Trace Tab On Remove Circuit Window    ${Pair 4}
	Uncheck Remove Patching On Remove Circuit Window    2    clickNext=${False}
	Select View Trace Tab On Remove Circuit Window    ${Pair 6}
	Uncheck Remove Patching On Remove Circuit Window    2    clickNext=${True}
	# 10. Create Remove Circuit job
	Create Work Order    ${wo_remove_circuit}
	Wait For Work Order Icon On Content Table    ${01}
	
	# 11. Complete job at step 6 and step 10
	Open Work Order Queue Window
	Complete Work Order    ${wo_patching},${wo_remove_circuit}
	Close Work Order Queue
	
    # 12. Trace Panel 01/01 and observe the circuit
    Open Trace Window    ${tree_node_panel_1}    ${01} 
    Select View Trace Tab On Site Manager    ${Pair 1}
    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=1 [${Pair 1}]	
    ...    objectPath=${tree_node_server_1}/${01}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    ...    informationDevice=${01}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
	Select View Trace Tab On Site Manager    ${Pair 3}
    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=3 [${Pair 3}]	
    ...    objectPath=${tree_node_server_1}/${03}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    ...    informationDevice=${03}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
	Select View Trace Tab On Site Manager    ${Pair 5}
    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=5 [${Pair 5}]	
    ...    objectPath=${tree_node_server_1}/${05}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    ...    informationDevice=${05}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
	Select View Trace Tab On Site Manager    ${Pair 2}
	Check Trace Object On Site Manager    indexObject=2    objectPosition=2 [${Pair 2}]	
    ...    objectPath=${tree_node_switch_1}/${02}    objectType=${TRACE_SWITCH_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}	
    ...    informationDevice=${02}->${SWITCH_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}	
    ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}	
    ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=5    objectPosition=2 [${Pair 2}]	
    ...    objectPath=${tree_node_server_1}/${02}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}	
    ...    informationDevice=${02}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
    Select View Trace Tab On Site Manager    ${Pair 4}
	Check Trace Object On Site Manager    indexObject=2    objectPosition=4 [${Pair 4}]	
    ...    objectPath=${tree_node_switch_1}/${04}    objectType=${TRACE_SWITCH_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}	
    ...    informationDevice=${04}->${SWITCH_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}	
    ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}	
    ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=5    objectPosition=4 [${Pair 4}]	
    ...    objectPath=${tree_node_server_1}/${04}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}	
    ...    informationDevice=${04}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
    Select View Trace Tab On Site Manager    ${Pair 6}
	Check Trace Object On Site Manager    indexObject=2    objectPosition=6 [${Pair 6}]	
    ...    objectPath=${tree_node_switch_1}/${06}    objectType=${TRACE_SWITCH_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}	
    ...    informationDevice=${06}->${SWITCH_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}	
    ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}	
    ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=5    objectPosition=6 [${Pair 6}]	
    ...    objectPath=${tree_node_server_1}/${06}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}	
    ...    informationDevice=${06}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Close Trace Window
	
	# 13. Observe port status on Content pane
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${in_use_3/6}    1
	Click Tree Node On Site Manager    ${tree_node_switch_1}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${03},${Available}    3
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${05},${Available}    5
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${02},${In Use}    2
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${04},${In Use}    4
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${06},${In Use}    6
	
	# 14. Select Switch 01/02 and remove circuit
	Open Remove Circuit Window    ${tree_node_switch_1}    ${02}
		
	# 15. Select "Remove all patch connections" option
	Remove Circuit
	
	# 16, Create "Remove Circuit" immediate job
	Create Work Order    ${wo_remove_circuit}    scheduling=Immediate
	Wait For Work Order Icon On Content Table    ${02}
	
	# 17. Complete this job
	Open Work Order Queue Window
	Complete Work Order    ${wo_remove_circuit}
	Close Work Order Queue
	
	# 18. Trace Panel 01/01 and observe the circuit
	Open Trace Window    ${tree_node_panel_1}    ${01} 
    Select View Trace Tab On Site Manager    ${Pair 1}
    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}	
    ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}	
    ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=1 [${Pair 1}]	
    ...    objectPath=${tree_node_server_1}/${01}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    ...    informationDevice=${01}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
	Select View Trace Tab On Site Manager    ${Pair 3}
    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=3 [${Pair 3}]	
    ...    objectPath=${tree_node_server_1}/${03}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    ...    informationDevice=${03}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
	Select View Trace Tab On Site Manager    ${Pair 5}
    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=5 [${Pair 5}]	
    ...    objectPath=${tree_node_server_1}/${05}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    ...    informationDevice=${05}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
	Select View Trace Tab On Site Manager    ${Pair 2}
	Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}	
    ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
    Check Trace Object On Site Manager    indexObject=3	    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}

    Select View Trace Tab On Site Manager    ${Pair 4}
	Check Trace Object On Site Manager    indexObject=2    objectPosition=4 [${Pair 4}]	
    ...    objectPath=${tree_node_switch_1}/${04}    objectType=${TRACE_SWITCH_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}	
    ...    informationDevice=${04}->${SWITCH_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}	
    ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}	
    ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=5    objectPosition=4 [${Pair 4}]	
    ...    objectPath=${tree_node_server_1}/${04}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}	
    ...    informationDevice=${04}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
    Select View Trace Tab On Site Manager    ${Pair 6}
	Check Trace Object On Site Manager    indexObject=2    objectPosition=6 [${Pair 6}]	
    ...    objectPath=${tree_node_switch_1}/${06}    objectType=${TRACE_SWITCH_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}	
    ...    informationDevice=${06}->${SWITCH_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}	
    ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]	
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}	
    ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=5    objectPosition=6 [${Pair 6}]	
    ...    objectPath=${tree_node_server_1}/${06}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledInUse}	
    ...    informationDevice=${06}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Close Trace Window
	
	# 19. Observe port status on Content pane
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${in_use_2/6}    1
	Click Tree Node On Site Manager    ${tree_node_switch_1}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${03},${Available}    3
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${05},${Available}    5
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${02},${Available}    2
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${04},${In Use}    4
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${06},${In Use}    6
	
SM-30124_04_Verify that the user can change sevice/remove circuit for 6xLC EB with circuit: LC Switch -> cabled 6xLC to -> MPO12 Panel -> F2B cabling to -> MPO12 Panel -> patched 4xLC to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-30124-04
    ...    AND    Delete Building     ${building_name}
    ...    AND    Add New Building    ${building_name}    
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}

    [Teardown]    Run Keywords    Delete Building     ${building_name}
    ...    AND    Close Browser
    
    ${position_rack_name_1}    Set Variable    1:1 Rack 001
    ${tree_node_panel_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_1}
    ${tree_node_panel_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_2}
    ${tree_node_server_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${SERVER_NAME_1}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${SWITCH_NAME_1}
    ${wo_patching}    Set Variable    add_patch
    ${wo_change_service}    Set Variable    change_service
    ${wo_remove_circuit}    Set Variable    remove_circuit
    
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${building_name}
        
	# 3. Add to Rack 001:
	# _LC Switch 01
	# _MPO Generic Panel 01
	# _MPO Generic Panel 02
	# _LC Server 01
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME_1}    roomName=${ROOM_NAME_1}    rackName=${RACK_NAME_1}
	Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}   
    ...    name=${PANEL_NAME_1}     portType=${MPO}    quantity=2
    Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}    ${SERVER_NAME_1}    
	Add Device In Rack Port    ${tree_node_server_1}    ${01}      portType=${LC}    quantity=6    
	Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}    ${SWITCH_NAME_1}    
	Add Network Equipment Port    ${tree_node_switch_1}    ${01}    portType=${LC}    listChannel=${01}    listServiceType=${Data}
	Add Network Equipment Port    ${tree_node_switch_1}    ${02}    portType=${LC}    listChannel=${02}    listServiceType=${Voice}
	
	# 4. Cable 6xLC EB from Panel 01/01 to Switch 01/01
	Open Cabling Window    ${tree_node_panel_1}    ${01}
	Create Cabling    cableFrom=${tree_node_panel_1}/${01}    cableTo=${tree_node_switch_1}    
	...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1}    portsTo=${01}
	Close Cabling Window
	  
	# 5. F2B Cabling from Panel 01/01 to Panel 02/01
	Open Front To Back Cabling Window    ${tree_node_panel_1}    ${01}
	Create Front To Back Cabling    cabFrom=${tree_node_panel_1}    cabTo=${tree_node_panel_2}    portsFrom=${01}    portsTo=${01}    
	Close Front To Back Cabling Window
	
	# 6. Patch 4xLC from Panel 02/01 to Server 01/01-04 and complete job
	# 7. Set Data service for Switch 01/01 and Set Voice service for Switch 01/02
    Open Patching Window    ${tree_node_panel_2}    ${01}
	Create Patching    patchFrom=${tree_node_panel_2}    patchTo=${tree_node_server_1}    
	...    portsFrom=${01}    portsTo=${01},${02},${03},${04}    
	...    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    
	...    mpoBranches=${1-1},${2-2},${3-3},${4-4}
	...    createWo=${False}
	
    # 8. Select Server 01/01 and change service
	# 9. Select Voice service in Change Service window > New Service
	# 10. Search Service and observe
	# 11. Click Show link and observe the cicuit
	# 12. Create Change service job and observe port status
	Open Services Window    serviceType=Change Service    treeNode=${tree_node_server_1}    objectName=${01}
    Change Service    service=${Voice}
    Create Work Order    ${wo_change_service}
    Wait For Work Order Icon On Content Table    ${01}
    
    # 13. Complete job above and observe port status
    Open Work Order Queue Window
    Complete Work Order    ${wo_change_service}
    Close Work Order Queue

	# 14. Trace Panel 01/01 and observe the circuit
	Open Trace Window    ${tree_node_panel_1}    ${01}
	Select View Trace Tab On Site Manager    ${Pair 1}
	Check Total Trace On Site Manager    4
	Check Trace Object On Site Manager    indexObject=1    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
	...    objectType=${TRACE_SERVICE}    connectionType=${TRACE_ASSIGN}    
	...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}      
	Check Trace Object On Site Manager    indexObject=2    objectPosition=1 [${Pair 1}]    
	...    objectPath=${tree_node_switch_1}/${01}    objectType=${TRACE_SWITCH_IMAGE}    
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${SWITCH_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_4LC_PATCHING}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
    Select View Trace Tab On Site Manager    ${Pair 2}
	Check Total Trace On Site Manager    3
	Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=2 [${2-2}]    
	...    objectPath=${tree_node_server_1}/${02}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
	...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_MPO12_4LC_PATCHING}
	...    informationDevice=${02}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
    Select View Trace Tab On Site Manager    ${Pair 3}
	Check Total Trace On Site Manager    3
	Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=3 [${3-3}]    
	...    objectPath=${tree_node_server_1}/${03}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
	...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_MPO12_4LC_PATCHING}
	...    informationDevice=${03}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
	Select View Trace Tab On Site Manager    ${Pair 4}
	Check Total Trace On Site Manager    3
	Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=4 [${4-4}]    
	...    objectPath=${tree_node_server_1}/${04}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
	...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_MPO12_4LC_PATCHING}
	...    informationDevice=${04}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
	Report Bug    ${SM-30437}
    # Select View Trace Tab On Site Manager    ${Pair 5}
	# Check Total Trace On Site Manager    2
	# Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	# ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}     
	# ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	# Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    
	# ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${No Path}  connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}s
	# ...    informationDevice=${No Path}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
    # Select View Trace Tab On Site Manager    ${Pair 6}
	# Check Total Trace On Site Manager    2
	# Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	# ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	# ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	# Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    
	# ...    objectPath=${tree_node_panel_2}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${No Path}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	# ...    informationDevice=${No Path}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Close Trace Window
	
	# 15. Trace Panel 02/01 and observe the circuit
	Open Trace Window    ${tree_node_panel_2}    ${01}
	Select View Trace Tab On Site Manager    ${1-1}
	Check Total Trace On Site Manager    4
	Check Trace Object On Site Manager    indexObject=1    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
	...    objectType=${TRACE_SERVICE}    connectionType=${TRACE_ASSIGN}    
	...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}      
	Check Trace Object On Site Manager    indexObject=2    objectPosition=1 [${Pair 1}]    
	...    objectPath=${tree_node_switch_1}/${01}    objectType=${TRACE_SWITCH_IMAGE}    
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${SWITCH_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_4LC_PATCHING}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
    Select View Trace Tab On Site Manager    ${2-2}
	Check Total Trace On Site Manager    3
	Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=2 [${2-2}]    
	...    objectPath=${tree_node_server_1}/${02}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
	...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_MPO12_4LC_PATCHING}
	...    informationDevice=${02}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
    Select View Trace Tab On Site Manager    ${3-3}
	Check Total Trace On Site Manager    3
	Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=3 [${3-3}]    
	...    objectPath=${tree_node_server_1}/${03}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
	...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_MPO12_4LC_PATCHING}
	...    informationDevice=${03}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
	Select View Trace Tab On Site Manager    ${4-4}
	Check Total Trace On Site Manager    3
	Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=4 [${4-4}]    
	...    objectPath=${tree_node_server_1}/${04}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
	...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_MPO12_4LC_PATCHING}
	...    informationDevice=${04}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
    Close Trace Window
    
	# 16. Trace Switch 01/02 and observe the circuit
	Open Trace Window    ${tree_node_switch_1}    ${02}
	Check Total Trace On Site Manager    3
	Check Trace Object On Site Manager    indexObject=1    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Voice}    
	...    objectType=${TRACE_SERVICE}    connectionType=${TRACE_ASSIGN}    
	...    informationDevice=${TRACE_OBJECT_SERVICE}->${Voice}->${TRACE_VLAN}->${TRACE_CONFIG}      
	Check Trace Object On Site Manager    indexObject=2    objectPosition=2    
	...    objectPath=${tree_node_switch_1}/${02}    objectType=${TRACE_SWITCH_IMAGE}    
	...    portIcon=${PortNEFDServiceInUse}    connectionType=${TRACE_FIBER_PATCHING}    
	...    informationDevice=${02}->${SWITCH_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	Check Trace Object On Site Manager    indexObject=3    objectPosition=1    
	...    objectPath=${tree_node_server_1}/${01}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
	...    portIcon=${PortFDUncabledInUse}
	...    informationDevice=${01}->${SERVER_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Close Trace Window
	
	# 17. Select Panel 01/01 and remove circuit
	Open Remove Circuit Window    ${tree_node_panel_1}    ${01}
	    
	# 18. Select " Remove all patch connections" option
	Remove Circuit    
	# 19. Create Remove Circuit job and complete this job
	Create Work Order    ${wo_remove_circuit}
	Click Tree Node On Site Manager    ${tree_node_panel_2}
    Wait For Work Order Icon On Content Table    ${01}    	
     
    Open Work Order Queue Window
    Complete Work Order    ${wo_remove_circuit}    
	Close Work Order Queue
	
	# 20. Observe the port status
	Click Tree Node On Site Manager    ${tree_node_server_1}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${02},${Available}    2
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${03},${Available}    3
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${04},${Available}    4
	Click Tree Node On Site Manager    ${tree_node_panel_2}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
	
	# 21: Trace Panel 01/01 and observe the circuit
	Open Trace Window    ${tree_node_panel_1}    ${01}
	Select View Trace Tab On Site Manager    ${Pair 1}
	Check Total Trace On Site Manager    4
	Check Trace Object On Site Manager    indexObject=1    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
	...    objectType=${TRACE_SERVICE}    connectionType=${TRACE_ASSIGN}    
	...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}      
	Check Trace Object On Site Manager    indexObject=2    objectPosition=1 [${Pair 1}]    
	...    objectPath=${tree_node_switch_1}/${01}    objectType=${TRACE_SWITCH_IMAGE}    
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${SWITCH_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledAvailable}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
    Select View Trace Tab On Site Manager    ${Pair 2}
	Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledAvailable}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
    Select View Trace Tab On Site Manager    ${Pair 3}
	Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledAvailable}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
	Select View Trace Tab On Site Manager    ${Pair 4}
	Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledAvailable}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
    Select View Trace Tab On Site Manager    ${Pair 5}
	Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledAvailable}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	
    Select View Trace Tab On Site Manager    ${Pair 6}
	Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    
	...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	...    portIcon=${PortMPOPanelCabledAvailable}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}
	Close Trace Window

# Invalid TC due to design changed	
# SM-30124_05_Verify that the user can move device/remove circuit for 6xLC EB with circuit: LC Switch -> cabled 4xLC to -> MPO12 Panel 01 -> patched ->MPO12 Panel 02 -> cabled -> MPO12 Panel 03 -> patched 6xLC -> LC Panel 04 -> cabled to -> LC Faceplate
    # [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-30124-05
    # ...    AND    Delete Building     ${building_name}
    # ...    AND    Add New Building    ${building_name}    
    # ...    AND    Open SM Login Page
    # ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}

    # [Teardown]    Run Keywords    Delete Building     ${building_name}
    # ...    AND    Close Browser
    
    # ${position_rack_name_1}    Set Variable    1:1 Rack 001
    # ${position_rack_name_2}    Set Variable    1:1 Rack 002
    # ${tree_node_panel_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_1}
    # ${tree_node_panel_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_2}
    # ${tree_node_panel_3}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_3}
    # ${tree_node_panel_4}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${PANEL_NAME_4}    
    # ${tree_node_panel_5}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}/${PANEL_NAME_5}
    # ${tree_node_panel_6}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}/${PANEL_NAME_6}
    # ${tree_node_panel_7}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}/${PANEL_NAME_7}
    # ${tree_node_panel_8}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}/${PANEL_NAME_8}    
    # ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}/${SWITCH_NAME_1}
    # ${tree_node_switch_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}/${SWITCH_NAME_2}
    # ${tree_node_faceplate_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${FACEPLATE_1}
    # ${tree_node_faceplate_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${FACEPLATE_2}
    # ${tree_node_room_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}
    # ${tree_node_room_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}
    # ${wo_name}    Set Variable    SM-30124_02
    # ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    # ${person_first_name}    Set Variable    Test
    # ${person_last_name}    Set Variable    Person
    # ${person_name}    Set Variable    ${person_last_name}, ${person_first_name}
    
    # Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${building_name}    
    # # * On SM:
	# # 3. Add to Room 01:
	# # _LC Faceplate 01
	# # _Device 01
	# # 4. Add Room 01/1:1 Rack 001
	# # _LC Switch 01 (set Data service for port 01)
	# # _MPO Generic Panel 01
	# # _MPO Generic Panel 02
	# # _MPO Generic Panel 03
	# # _LC Panel 04
	# # 5. Add to Room 02:
	# # _LC Facepalate 01
	# # 6. Add to Room 02/Rack 001:
	# # _LC Switch 01 (set Data service for port 01)
	# # _MPO Generic Panel 01
	# # _MPO Generic Panel 02
	# # _MPO Generic Panel 03
	# # _LC Panel 04
    # Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME_1}    roomName=${ROOM_NAME_1}    rackName=${RACK_NAME_1}
	# Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}    ${ROOM_NAME_2}    
	# Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}    ${RACK_NAME_2}
	# Add Device    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}    ${Computer}    ${DEVICE_NAME_1}    
	# Add Faceplate    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}    ${FACEPLATE_1}    ${LC}
	# Add Faceplate    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}    ${FACEPLATE_2}    ${LC}
	# Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}    ${SWITCH_NAME_1}    
	# Add Network Equipment Port    ${tree_node_switch_1}    ${01}       portType=${LC}    
	# ...    listChannel=${01}    listServiceType=${Data} 
	# Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}    ${SWITCH_NAME_2}    
	# Add Network Equipment Port    ${tree_node_switch_2}    ${01}       portType=${LC}    
	# ...    listChannel=${01}    listServiceType=${Data}
	# Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}    
	# ...    name=${PANEL_NAME_1}    portType=${MPO}    quantity=3
    # Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_1}/${position_rack_name_1}    
	# ...    name=${PANEL_NAME_4}    portType=${LC}
    # Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}    
	# ...    name=${PANEL_NAME_5}    portType=${MPO}    quantity=3
    # Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME_2}/${position_rack_name_2}    
	# ...    name=${PANEL_NAME_8}    portType=${LC}
	
	# # 7. Create connection in Room 01 and Room 02:
	# # _Cable 4xLC from Panel 01/01 to Switch 01/01
	# # _Patch MPO12-MPO12 from Panel 01/01 to Panel 02/01 and complete this job
	# # _Cable from Panel 02/01 to Panel 03/01
	# # 8. Patch 6xLC EB from Panel 03/01 to Panel 04/01-06
	# # 9. Cable from Panel 04/01-06 to Faceplate 01/01-06 in Room 2
	# # 10. Cable from Panel 04/01 to Faceplate 01/01 in Room 01 and connect Device 01 to Faceplate 01/01
	# Open Cabling Window    ${tree_node_panel_1}    ${01}
	# Create Cabling    cableFrom=${tree_node_panel_1}/${01}    cableTo=${tree_node_switch_1}    
	# ...    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    mpoBranches=${1-1}    portsTo=${01}
	# Create Cabling    cableFrom=${tree_node_panel_5}/${01}    cableTo=${tree_node_switch_2}    
	# ...    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    mpoBranches=${1-1}    portsTo=${01}
	# Create Cabling    cableFrom=${tree_node_panel_2}/${01}    cableTo=${tree_node_panel_3}    portsTo=${01}
	# ...    mpoTab=${MPO12}    mpoType=${Mpo12_Mpo12}
	# Create Cabling    cableFrom=${tree_node_panel_6}/${01}    cableTo=${tree_node_panel_7}    portsTo=${01}
	# ...    mpoTab=${MPO12}    mpoType=${Mpo12_Mpo12}
	# Create Cabling    cableFrom=${tree_node_panel_4}/${01}    cableTo=${tree_node_faceplate_1}    portsTo=${01}
	# Create Cabling    cableFrom=${tree_node_panel_8}/${01}    cableTo=${tree_node_faceplate_2}    portsTo=${01}
	# Close Cabling Window
	
	# Open Patching Window    ${tree_node_panel_1}    ${01}
	# Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_panel_2}    portsFrom=${01}    portsTo=${01}  
	# ...    mpoTab=${MPO12}    mpoType=${Mpo12_Mpo12}
	# ...    clickNext=${False}
	# Create Patching    patchFrom=${tree_node_panel_5}    patchTo=${tree_node_panel_6}    portsFrom=${01}    portsTo=${01}  
	# ...    mpoTab=${MPO12}    mpoType=${Mpo12_Mpo12}
	# ...    clickNext=${False}
	# Create Patching    patchFrom=${tree_node_panel_3}    patchTo=${tree_node_panel_4}    portsFrom=${01}    
	# ...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}	
	# ...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    
	# ...    portsTo=${01},${02},${03},${04},${05},${06}  
	# ...    createWo=${False}
	# ...    clickNext=${True}
	
	
	# Open Patching Window    ${tree_node_faceplate_1}    ${01}
	# Create Patching    patchFrom=${tree_node_faceplate_1}    patchTo=${tree_node_room_1}    portsFrom=${01}    portsTo=${DEVICE_NAME_1}    
	
	# # 11. Select Room 01/Device 01 and move service
	# # 12. Select Room 02 in Move To pane and go next screen
	# # 13. In Move Service for Device 01 window, select Faceplate 01/01 in Room 02 and search service
    # Open Services Window    serviceType=Move Services    treeNode=${tree_node_room_1}    objectName=${DEVICE_NAME_1}
    # Move Services    moveTo=${tree_node_room_2}    moveServiceTo=${tree_node_faceplate_2}/${01}
    # Create Work Order    ${wo_name}
    # Wait For Work Order Icon On Content Table    ${DEVICE_NAME_1}
    
    # # * Step 17:
	# # _Panel 03/01, Panel 04/01: Available-Pending
	# # _Faceplate 01/01: Available-Pending
	# # _Switch 01/01-04: In Use
	# # _Panel 01/01: In Use
	# # _Panel 01/02: In Use
	# Click Tree Node On Site Manager    ${tree_node_panel_1}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${In Use}    1    
    # Click Tree Node On Site Manager    ${tree_node_panel_2}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${In Use}    1    
	# Click Tree Node On Site Manager    ${tree_node_panel_3}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${Available - Pending}    1    
    # Click Tree Node On Site Manager    ${tree_node_panel_4}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${Available - Pending}    1    
    # Click Tree Node On Site Manager    ${tree_node_faceplate_1}
    # Check Table Row Map With Header On Content Table    ${name},${Panel Port Status}    ${01},${Available - Pending}    1    
    # Click Tree Node On Site Manager    ${tree_node_switch_1}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${In Use}    1    

	# # * Step 18:
	# # _Panel 03/01, Panel 04/01: In Use -Pending
	# # _Faceplate 01/01: In Use -Pending
	# # _Switch 01/01-04: In Use
	# # _Panel 01/01: In Use
	# # _Panel 01/02: In Use
    # Click Tree Node On Site Manager    ${tree_node_panel_5}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${In Use}    1 
    # Click Tree Node On Site Manager    ${tree_node_panel_6}   
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${In Use}    1    
	# Click Tree Node On Site Manager    ${tree_node_panel_7}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${In Use - Pending}    1    
    # Click Tree Node On Site Manager    ${tree_node_panel_8}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${In Use - Pending}    1    
    # Click Tree Node On Site Manager    ${tree_node_faceplate_2}
    # Check Table Row Map With Header On Content Table    ${name},${Panel Port Status}    ${01},${In Use - Pending}    1    
    # Click Tree Node On Site Manager    ${tree_node_switch_2}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${In Use}    1    

    # # 19. Clear "Device Moved" priority event
    # Open Events Window
    # Clear Event On Event Log    All    
    # Close Event Log
    
	# # 20. Complete job above
	# Open Work Order Queue Window
	# Complete Work Order    ${wo_name}    
	# Close Work Order Queue
	
	# # 21. Trace Panel 03/01 in Room 01 and observe the circuit
	# Open Trace Window    ${tree_node_panel_3}    ${01}    
	# Select View Trace Tab On Site Manager    ${Pair 1}
	# Check Total Trace On Site Manager    5
	# Check Trace Object On Site Manager    indexObject=1    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
	# ...    objectType=${TRACE_SERVICE}    connectionType=${TRACE_ASSIGN}    
	# ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}      
	# Check Trace Object On Site Manager    indexObject=2    objectPosition=1 [${1-1}]    
	# ...    objectPath=${tree_node_switch_1}/${01}    objectType=${TRACE_SWITCH_IMAGE}    
	# ...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_4X_MPO12_FRONT_BACK_CABLING}    
	# ...    informationDevice=${01}->${SWITCH_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
	# ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1    
	# ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=5    mpoType=12    objectPosition=1 [${A1}]    
	# ...    objectPath=${tree_node_panel_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_3}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	
    # Select View Trace Tab On Site Manager    ${Pair 2}
    # Check Total Trace On Site Manager    4
    # Check Trace Object On Site Manager    indexObject=1    objectPosition=2 [${Pair 2}]    
	# ...    objectPath=${tree_node_panel_4}/${02}    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    
	# ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
	# ...    informationDevice=${02}->${PANEL_NAME_4}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
	# ...    objectPath=${tree_node_panel_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_3}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1    
	# ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [ /${A1}]    
	# ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO_4X_LC_BACK_FRONT_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	
    # Select View Trace Tab On Site Manager    ${Pair 3}
    # Check Total Trace On Site Manager    4
    # Check Trace Object On Site Manager    indexObject=1    objectPosition=3 [${Pair 3}]    
	# ...    objectPath=${tree_node_panel_4}/${03}    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    
	# ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
	# ...    informationDevice=${03}->${PANEL_NAME_4}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
	# ...    objectPath=${tree_node_panel_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_3}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1    
	# ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [ /${A1}]    
	# ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO_4X_LC_BACK_FRONT_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	
    # Select View Trace Tab On Site Manager    ${Pair 4}
    # Check Total Trace On Site Manager    4
    # Check Trace Object On Site Manager    indexObject=1    objectPosition=4 [${Pair 4}]    
	# ...    objectPath=${tree_node_panel_4}/${04}    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    
	# ...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
	# ...    informationDevice=${04}->${PANEL_NAME_4}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
	# ...    objectPath=${tree_node_panel_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_3}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1    
	# ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [ /${A1}]    
	# ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO_4X_LC_BACK_FRONT_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Close Trace Window
	
	# Report Bug    ${SM-30437}
	
	# # 22. Trace Panel 03/01 in Room 02 and observe the circuit
	# Open Trace Window    ${tree_node_panel_7}    ${01}    
	# Select View Trace Tab On Site Manager    ${1-1}
	# Check Total Trace On Site Manager    8
	# Check Trace Object On Site Manager    indexObject=1    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
	# ...    objectType=${TRACE_SERVICE}    connectionType=${TRACE_ASSIGN}    
	# ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}      
	# Check Trace Object On Site Manager    indexObject=2    objectPosition=1 [${1-1}]    
	# ...    objectPath=${tree_node_switch_2}/${01}    objectType=${TRACE_SWITCH_IMAGE}    
	# ...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_4X_MPO12_FRONT_BACK_CABLING}    
	# ...    informationDevice=${01}->${SWITCH_NAME_2}->${position_rack_name_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
	# ...    objectPath=${tree_node_panel_5}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_5}->${position_rack_name_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1    
	# ...    objectPath=${tree_node_panel_6}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_6}->${position_rack_name_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=5    mpoType=12    objectPosition=1 [${A1}]   
	# ...    objectPath=${tree_node_panel_7}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_4LC_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_7}->${position_rack_name_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=6    objectPosition=1 [${1-1}]   
	# ...    objectPath=${tree_node_panel_8}/${01}    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    
	# ...    portIcon=${PortFDCabledInUse}    connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_8}->${position_rack_name_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=7    objectPosition=1   
	# ...    objectPath=${tree_node_faceplate_2}/${01}    objectType=${TRACE_LC_FACEPLATE_IMAGE}    
	# ...    portIcon=${PortFDCabledInUse}    connectionType=${TRACE_FIBER_PATCHING}
	# ...    informationDevice=${01}->${FACEPLATE_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=8   
	# ...    objectPath=${tree_node_room_2}/${DEVICE_NAME_1}    objectType=${TRACE_COMPUTER_IMAGE}
	# ...    informationDevice=${DEVICE_NAME_1}->${TRACE_OBJECT_IP}->${EMPTY}->${TRACE_OBJECT_MAC}

    # ${pair list}    Create List   ${2-2}    ${3-3}    ${4-4}
    # :FOR    ${i}    IN RANGE    len(${pair list})
    # \    Select View Trace Tab On Site Manager    ${pair list}[${i}]
	# \    Check Total Trace On Site Manager    3
	# \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [${A1}]    
	# ...    objectPath=${tree_node_panel_7}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_LC_4X_MPO12_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_7}->${position_rack_name_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    
	# ...    objectPath=${tree_node_panel_6}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_6}->${position_rack_name_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
	# ...    objectPath=${tree_node_panel_5}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_5}->${position_rack_name_2}->${ROOM_NAME_2}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# \    Check Trace Object On Site Manager    indexObject=4    connectionType=${TRACE_MPO_4X_LC_BACK_FRONT_CABLING}
	# Close Trace Window
	
	# # 23. Select Panel 03/01 in Room 01 and remove circuit
	# # 24. Set
	# # _Set on "Remove all patch connections" 
	# # options
	# # _Uncheck "Create Work Order "
	# Open Remove Circuit Window    ${tree_node_panel_3}    ${01}
	# Remove Circuit    createWo=${False}
	
	# # 25. Complete and observe
	# # 26. Observe ports status in Room 01
	# Click Tree Node On Site Manager    ${tree_node_panel_1}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${Available}    1    
    # Click Tree Node On Site Manager    ${tree_node_panel_2}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${Available}    1    
	# Click Tree Node On Site Manager    ${tree_node_panel_3}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${Available}    1    
    # Click Tree Node On Site Manager    ${tree_node_panel_4}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${Available}    1    
    # Click Tree Node On Site Manager    ${tree_node_faceplate_1}
    # Check Table Row Map With Header On Content Table    ${name},${Panel Port Status}    ${01},${Available}    1    
    # Click Tree Node On Site Manager    ${tree_node_switch_1}
    # Check Table Row Map With Header On Content Table    ${name},${Port Status}    ${01},${Available}    1    

	# # 27. Trace Panel 01/01 in Room 01 and observe the circuit
	# Open Trace Window    ${tree_node_panel_1}    ${01}    
	# Select View Trace Tab On Site Manager    ${1-1}
	# Check Total Trace On Site Manager    3
	# Check Trace Object On Site Manager    indexObject=1    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
	# ...    objectType=${TRACE_SERVICE}    connectionType=${TRACE_ASSIGN}    
	# ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}      
	# Check Trace Object On Site Manager    indexObject=2    objectPosition=1 [${1-1}]    
	# ...    objectPath=${tree_node_switch_1}/${01}    objectType=${TRACE_SWITCH_IMAGE}    
	# ...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_4X_MPO12_FRONT_BACK_CABLING}    
	# ...    informationDevice=${01}->${SWITCH_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
	# ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOServiceCabledAvailable}    
	# ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	
    # ${pair list}    Create List   ${2-2}    ${3-3}    ${4-4}
    # :FOR    ${i}    IN RANGE    len(${pair list})
    # \    Select View Trace Tab On Site Manager    ${pair list}[${i}]
	# \    Check Total Trace On Site Manager    1
	# \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]    
	# ...    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOServiceCabledAvailable}    connectionType=${TRACE_MPO_4X_LC_BACK_FRONT_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_1}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Close Trace Window
	
	# # 28. Trace Panel 02/01 in Room 01 and observe the circuit
	# Open Trace Window    ${tree_node_panel_2}    ${01}    
	# Check Total Trace On Site Manager    2
	# Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1    
	# ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledAvailable}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_2}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    
	# ...    objectPath=${tree_node_panel_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	# ...    portIcon=${PortMPOPanelCabledAvailable}
	# ...    informationDevice=${01}->${PANEL_NAME_3}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Close Trace Window
	
	# # 29. Trace Panel 04/01 in Room 01 and observe the circuit
    # Open Trace Window    ${tree_node_panel_4}    ${01}    
	# Check Total Trace On Site Manager    2
	# Check Trace Object On Site Manager    indexObject=1    objectPosition=1    
	# ...    objectPath=${tree_node_panel_4}/${01}    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    
	# ...    portIcon=${PortFDCabledAvailable}    connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}
	# ...    informationDevice=${01}->${PANEL_NAME_4}->${position_rack_name_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Check Trace Object On Site Manager    indexObject=2    objectPosition=1    
	# ...    objectPath=${tree_node_faceplate_1}/${01}    objectType=${TRACE_LC_FACEPLATE_IMAGE}    
	# ...    portIcon=${PortFDCabledAvailable}
	# ...    informationDevice=${01}->${FACEPLATE_1}->${ROOM_NAME_1}->${FLOOR_NAME_1}->${building_name}->${SITE_NODE}       
	# Close Trace Window

