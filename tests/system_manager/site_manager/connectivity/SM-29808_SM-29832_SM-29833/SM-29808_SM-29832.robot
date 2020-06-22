*** Settings ***
Resource    ../../../../../resources/constants.robot       
Resource    ../../../../../resources/icons_constants.robot  

Library    ../../../../../py_sources/logigear/setup.py     
Library    ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py        
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py       
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/work_order_queue/WorkOrderQueuePage${PLATFORM}.py     
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/front_to_back_cabling/FrontToBackCablingPage${PLATFORM}.py    

Default Tags    Connectivity
Force Tags    SM-29808_SM-29832_SM-29833

*** Variables ***
${FLOOR_NAME}    Floor 01
${ROOM_NAME}    Room 01
${RACK_NAME}    Rack 001
${RACK_POSITION}    ${ZONE}:${POSITION} ${RACK_NAME}
${SWITCH_NAME_1}    Switch 01
${SWITCH_NAME_2}    Switch 02
${SERVER_NAME_1}    Server 01
${SERVER_NAME_2}    Server 02
${CARD_NAME_1}    Card 01
${PANEL_NAME_1}   Panel 01
${PANEL_NAME_2}    Panel 02
${PANEL_NAME_3}    Panel 03
${ZONE}    1
${POSITION}    1

*** Test Cases ***
SM-29808_SM-29832_06_Verify that the service is propagated and trace correctly in customer circuit: LC Switch -> cabled 6xLC to -> MPO12 Panel -> F2B cabling to -> MPO12 Panel -> patched 6xLC to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-29808-29832_06
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}
    
    ##Set variables##
    ${wo_name}    Set Variable    WO001
    ${tree_node_panel_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_1}
    ${tree_node_panel_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_2}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${SWITCH_NAME_1}
    ${tree_node_server_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${SERVER_NAME_1}/${CARD_NAME_1}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${pair_list}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    # 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add: 
	# _LC Switch 01 to Room 01
	# _MPO non-iPatch Panel 01 to Rack 001
	# _MPO Panel 02, LC Server 01 to Rack 001
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
	Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
	Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${SWITCH_NAME_1}
	Add Network Equipment Port    ${tree_node_switch_1}    name=${01}    portType=${LC}     listChannel=${01}    
	...    listServiceType=${Data}    quantity=6
	Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    name=${PANEL_NAME_1}   portType=${MPO}	quantity=2
	Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${SERVER_NAME_1}
	Add Device In Rack Component    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${SERVER_NAME_1}
	...    componentType=Device in Rack Card    name=${CARD_NAME_1}    portType=${LC}
	
	#  4. Set Data service for Switch 01// 01-06 directly
	#  5. Cable from Panel 01// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 01// 01-06
	Open Cabling Window    ${tree_node_panel_1}   ${01}
	Create Cabling    cableFrom=${tree_node_panel_1}/${01}    
	...    cableTo=${tree_node_switch_1}    mpoTab=${Mpo12}    mpoType=${Mpo12_6xLC_EB}    
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    
	...    portsTo=${01},${02},${03},${04},${05},${06}
	Close Cabling Window
	
	# 6. F2B cabling from Panel 01// 01 (MPO12-MPO12) to Panel 02// 01
	Open Front To Back Cabling Window    ${tree_node_panel_1}   ${01}
	Create Front To Back Cabling    cabFrom=${tree_node_panel_1}   cabTo=${tree_node_panel_2}    
	...    portsFrom=${01}    portsTo=${01}    mpoTab=${Mpo12}    mpoType=${Mpo12_Mpo12}
	Close Front To Back Cabling Window
	
	# 7. Create the Add Patch job and DO NOT complete the job with the tasks from Panel 02// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Server 01// 01-06
	Open Patching Window    ${tree_node_panel_2}     ${01}
	Create Patching    patchFrom=${tree_node_panel_2}    patchTo=${tree_node_server_1}
	...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}
	...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}	
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
	Create Work Order    ${wo_name}
	    
	# 8. Observe the port statuses, the propagated services and trace horizontal and vertical them
	Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUseScheduled}    ${tree_node_panel_2}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    1
    Select Object On Content Table    ${01}     
    Check Object Properties On Properties Pane    ${Service}    ${Data}    
    
	Click Tree Node On Site Manager    ${tree_node_server_1}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUseScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY}

    Click Tree Node On Site Manager    ${tree_node_panel_1}
    Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUse}    ${tree_node_panel_1} 
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}  
    
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
	
	# Trace Panel 01/01
    Open Trace Window    ${tree_node_panel_1}   ${01}
    Select View Type On Trace    Current
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    4
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]        
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1    
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    Scheduled
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    5
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${i_str} [${pair_list}[${i}]]        
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]    
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    scheduleIcon=${TRACE_SCHEDULED_IMAGE}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${i_str} [${pair_list}[${i}]]   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]	objectType=${TRACE_SERVER_CARD_IMAGE}    
    ...    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]
	\    Select View Type On Trace    Current
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
    
	# # 9. Complete the job above
	Open Work Order Queue Window
	Complete Work Order    ${wo_name}
	Close Work Order Queue
	
	# 10. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    ${tree_node_panel_2}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}    
    
    Click Tree Node On Site Manager    ${tree_node_server_1}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]  
    \    Check Object Properties On Properties Pane    ${Current Service}    ${Data}

    Click Tree Node On Site Manager    ${tree_node_panel_1} 
    Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUse}    ${tree_node_panel_1} 
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}  
    
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${empty},${Data}    
    
    Open Trace Window    ${tree_node_panel_1}    ${01}
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    5
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${i_str} [${pair_list}[${i}]]        
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]    
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${i_str} [${pair_list}[${i}]]   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]	objectType=${TRACE_SERVER_CARD_IMAGE}    
    ...    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
	# 11. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the tasks from Panel 02// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Server 01// 01-06
	Open Patching Window    ${tree_node_panel_2}    ${01}
	Create Patching    patchFrom=${tree_node_panel_2}    patchTo=${tree_node_server_1}
	...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}
	...    typeConnect=Disconnect
	...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}	
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
	Create Work Order    ${wo_name}
	
	# 12. Observe the port statuses, the propagated services and trace horizontal and vertical them
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledAvailableScheduled}    ${tree_node_panel_2}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}    
    
    Click Tree Node On Site Manager    ${tree_node_server_1}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledAvailableScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]  
    \    Check Object Properties On Properties Pane    ${Current Service}    ${Data}

    Click Tree Node On Site Manager    ${tree_node_panel_1} 
    Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUse}    ${tree_node_panel_1} 
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
    Select Object On Content Table    ${01}   
    Check Object Properties On Properties Pane    ${Service}    ${Data}  
    
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]  
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${empty},${Data}
    
    Open Trace Window    ${tree_node_panel_1}   ${01}
    Select View Type On Trace    Scheduled
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    4
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]        
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1    
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    Current
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    5
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${i_str} [${pair_list}[${i}]]        
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]    
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${i_str} [${pair_list}[${i}]]   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]	objectType=${TRACE_SERVER_CARD_IMAGE}    
    ...    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
	
	# 13. Complete the job above
	Open Work Order Queue Window
	Complete Work Order    ${wo_name}
	Close Work Order Queue
	
	# 14. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledAvailable}    ${tree_node_panel_2}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}    
    
    Click Tree Node On Site Manager    ${tree_node_server_1}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledAvailable}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY}

    Click Tree Node On Site Manager    ${tree_node_panel_1} 
    Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUse}    ${tree_node_panel_1} 
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}  
    
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}] 
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}
    
    Open Trace Window    ${tree_node_panel_1}   ${01}
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    4
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]        
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1    
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
    
SM-29808_SM-29832_07_Verify that the service is propagated and trace correctly in customer circuit: LC Switch -> cabled 6xLC to -> MPO12 Panel -> patched to -> MPO12 Panel -> cabled 6xLC to -> LC Switch
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-29808-29832_07
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}
   
    ##Set variables##
    ${wo_name}    Set Variable    WO002
    ${tree_node_panel_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_1}
    ${tree_node_panel_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_2}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${SWITCH_NAME_1}
    ${tree_node_switch_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${SWITCH_NAME_2}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${pair_list}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    # 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add: 
	# _LC Switch 01 to Room 01
	# _MPO Panel 01, MPO Panel 02, LC Switch 02 to Rack 001
	# 4. Set Data service for Switch 01// 01-06 directly
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
	Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
	Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${SWITCH_NAME_1}
	Add Network Equipment Port    ${tree_node_switch_1}    name=${01}    portType=${LC}     listChannel=${01}    
    ...    listServiceType=${Data}    quantity=6
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${SWITCH_NAME_2}
	Add Network Equipment Port    ${tree_node_switch_2}    name=${01}    portType=${LC}     quantity=6
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    name=${PANEL_NAME_1}   portType=${MPO}	quantity=2
    
    # 5. Cable from: 
	# _Panel 01// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 01// 01-06
	# _Panel 02// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 02// 01-06
	Open Cabling Window    ${tree_node_panel_1}   ${01}
	Create Cabling    cableFrom=${tree_node_panel_1}/${01}    
	...    cableTo=${tree_node_switch_1}    mpoTab=${Mpo12}    mpoType=${Mpo12_6xLC_EB}    
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    
	...    portsTo=${01},${02},${03},${04},${05},${06}
	Create Cabling    cableFrom=${tree_node_panel_2}/${01}    
	...    cableTo=${tree_node_switch_2}    mpoTab=${Mpo12}    mpoType=${Mpo12_6xLC_EB}    
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    
	...    portsTo=${01},${02},${03},${04},${05},${06}
	Close Cabling Window

	# 6. Create the Add Patch job and DO NOT complete the job with the tasks from Panel 01// 01 (MPO12-MPO12) to Panel 02// 01
    Open Patching Window    ${tree_node_panel_1}     ${01}
	Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_panel_2}
	...    portsFrom=${01}    portsTo=${01}
	...    mpoTab=${MPO12}    mpoType=${Mpo12_Mpo12}
	Create Work Order    ${wo_name}

    # 7. Observe the port statuses, the propagated services and trace horizontal and vertical them
    Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUseScheduled}    ${tree_node_panel_1}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUseScheduled}    ${tree_node_panel_2}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    1
    Select Object On Content Table    ${01}     
    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}
    
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
    
     Click Tree Node On Site Manager    ${tree_node_switch_2}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDPanelCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${EMPTY}
    
    ##Check Trace##
    Open Trace Window    ${tree_node_panel_1}   ${01}
    Select View Type On Trace    Current
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i+1} [${pair_list}[${i}]]    
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

    Select View Type On Trace    Scheduled
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    6
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i+1} [${pair_list}[${i}]]    
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_PATCHING}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}   
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    objectPosition=${i+1} [${pair_list}[${i}]]        
    ...    objectPath=${tree_node_switch_2}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_ASSIGN}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=6        
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${EMPTY}->${TRACE_VLAN}->${TRACE_CONFIG}
    Close Trace Window
    
    Open Trace Window    ${tree_node_panel_2}   ${01}
    Select View Type On Trace    Current
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${EMPTY}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i+1} [${pair_list}[${i}]]    
    ...    objectPath=${tree_node_switch_2}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
	# 8. Complete the job above
	Open Work Order Queue Window
	Complete Work Order    ${wo_name}
	Close Work Order Queue
		
	# 9. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUse}    ${tree_node_panel_1}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUse}    ${tree_node_panel_2}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
    
     Click Tree Node On Site Manager    ${tree_node_switch_2}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDPanelCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}
    
    Open Trace Window    ${tree_node_panel_1}    ${01}
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    6
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i+1} [${pair_list}[${i}]]    
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_PATCHING}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}   
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    objectPosition=${i+1} [${pair_list}[${i}]]        
    ...    objectPath=${tree_node_switch_2}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_ASSIGN}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=6        
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${EMPTY}->${TRACE_VLAN}->${TRACE_CONFIG}
    Close Trace Window
    
	# 10. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the tasks from Panel 01// 01 (MPO12-MPO12) to Panel 02// 01
	Open Patching Window    ${tree_node_panel_1}     ${01}
	Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_panel_2}
	...    portsFrom=${01}    portsTo=${01}    typeConnect=Disconnect
	...    mpoTab=${MPO12}    mpoType=${Mpo12_Mpo12}
	Create Work Order    ${wo_name}
	
	# 11. Observe the port statuses, the propagated services and trace horizontal and vertical them
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledAvailableScheduled}    ${tree_node_panel_1}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledAvailableScheduled}    ${tree_node_panel_2}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
    
     Click Tree Node On Site Manager    ${tree_node_switch_2}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDPanelCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}
    
        # ##Check Trace##
    Open Trace Window    ${tree_node_panel_1}   ${01}
    Select View Type On Trace    Scheduled
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i+1} [${pair_list}[${i}]]    
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

    Select View Type On Trace    Current
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    6
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i+1} [${pair_list}[${i}]]    
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_PATCHING}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}   
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    objectPosition=${i+1} [${pair_list}[${i}]]        
    ...    objectPath=${tree_node_switch_2}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_ASSIGN}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=6        
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${EMPTY}->${TRACE_VLAN}->${TRACE_CONFIG}
    Close Trace Window
    
    Open Trace Window    ${tree_node_panel_2}   ${01}
    Select View Type On Trace    Scheduled
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${EMPTY}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i+1} [${pair_list}[${i}]]    
    ...    objectPath=${tree_node_switch_2}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window

	# 12. Complete the job above
	Open Work Order Queue Window
	Complete Work Order    ${wo_name}
	Close Work Order Queue
	
	# 13. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledAvailable}    ${tree_node_panel_1}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledAvailable}    ${tree_node_panel_2}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}
    
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
    
     Click Tree Node On Site Manager    ${tree_node_switch_2}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDPanelCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${EMPTY}
    
    ##Check Trace##
    Open Trace Window    ${tree_node_panel_1}   ${01}
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i+1} [${pair_list}[${i}]]    
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_panel_2}   ${01}
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${EMPTY}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i+1} [${pair_list}[${i}]]    
    ...    objectPath=${tree_node_switch_2}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]    
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window

SM-29808_SM-29832_08_Verify that the service is propagated and trace correctly in customer circuit: LC Switch -> patched 6xLC to -> MPO12 Panel -> cabled to -> MPO12 Panel -> F2B cabling -> LC Panel -> patched to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-29808-29832_08
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}   

    ##Set Variable##
    ${wo_name}    Set Variable    WO003
    ${module_1a}    Set Variable    Module 1A (Pass-Through)
    ${module_1a_trace}    Set Variable    ..le 1A (Pass-Through)
    ${tree_node_panel_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_1}/${module_1a}
    ${tree_node_panel_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_2}/${module_1a}
    ${tree_node_panel_3}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_3}/${module_1a}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${SWITCH_NAME_1}
    ${tree_node_server_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${SERVER_NAME_1}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${pair_list}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001: 
	# _LC Switch 01
	# _MPO Panel 01
	# _MPO non-iPatch Panel 02
	# _LC Panel 03 (LC 12 Port - Pass-Through)
	# _LC Server 01
	# 4. Set Data service for Switch 01// 01-06 directly
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
	Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
	Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${SWITCH_NAME_1}
	Add Network Equipment Port    ${tree_node_switch_1}    name=${01}    portType=${LC}     listChannel=${01}    
    ...    listServiceType=${Data}    quantity=6
    Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    
    ...    systimaxEquipmentType=${360 G2 Fiber Shelf (1U)}    name=${PANEL_NAME_1}    multiModule=Module 1A,True,MPO (8 Port),Pass-Through    quantity=2
    Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    
    ...    systimaxEquipmentType=${360 G2 Fiber Shelf (1U)}    name=${PANEL_NAME_3}    multiModule=Module 1A,True,LC 12 Port,Pass-Through
	Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${SERVER_NAME_1}    
	Add Device In Rack Port    ${tree_node_server_1}    name=${01}    portType=${LC}    quantity=6
	
	# # 5. Cable from Panel 01// 01 (MPO12-MPO12) to Panel 02// 01
	Open Cabling Window    ${tree_node_panel_1}    ${01}
	Create Cabling    cableFrom=${tree_node_panel_1}/${01}    cableTo=${tree_node_panel_2}    mpoTab=${MPO12}    
	...    mpoType=${Mpo12_Mpo12}    portsTo=${01}
	Close Cabling Window
	
	# 6. F2B cabling from Panel 02// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Panel 03// 01-06
	Open Front To Back Cabling Window    ${tree_node_panel_2}    ${01}
	Create Front To Back Cabling    cabFrom=${tree_node_panel_2}    cabTo=${tree_node_panel_3}    
	...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    
	...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
	Close Front To Back Cabling Window
	
	# 7. Create the Add Patch job and DO NOT complete the job with the tasks from: 
	# _Panel 01// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 01// 01-06
	# _Panel 03// 01-06 to Server 01// 01-06
	Open Patching Window    ${tree_node_panel_3}    ${01}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Create Patching    patchFrom=${tree_node_panel_3}    patchTo=${tree_node_server_1}    
	...    portsFrom=${port_list}[${i}]    portsTo=${port_list}[${i}]    clickNext=${False}
	Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_switch_1}    
	...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    
	...    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    
	...    clickNext=${True}  
	Create Work Order    ${wo_name}
	
	# 8. Observe the port statuses, the propagated services and trace horizontal and vertical them
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUseScheduled}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}

    Click Tree Node On Site Manager    ${tree_node_panel_3}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDPanelCabledInUseScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}   
	
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceInUseScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
	
    Click Tree Node On Site Manager    ${tree_node_server_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUseScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY}    
	
	##Check Trace##
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_switch_1}    ${port_list}[${i}]
	\    Select View Type On Trace    Current
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str}   
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
        
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]
	\    Select View Type On Trace    Current
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window

    Open Trace Window    ${tree_node_panel_1}   ${01}
    Select View Type On Trace    Current
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1    
    ...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${module_1a_trace}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING_IMAGE}
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${module_1a_trace}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]	objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}   
    ...    informationDevice=${port_list}[${i}]->${module_1a_trace}->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    Scheduled
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    6
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]   
    ...    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    ...    scheduleIcon=${TRACE_SCHEDULED_IMAGE}
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${module_1a_trace}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING_IMAGE}
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${module_1a_trace}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    connectionType=${TRACE_FIBER_PATCHING}
    ...    scheduleIcon=${TRACE_SCHEDULED_IMAGE}
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]	objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}   
    ...    informationDevice=${port_list}[${i}]->${module_1a_trace}->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=6    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
	# 9. Complete the job above
	Open Work Order Queue Window
	Complete Work Order    ${wo_name}
	Close Work Order Queue

	# 10. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}

    Click Tree Node On Site Manager    ${tree_node_panel_3}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDPanelCabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service}    ${Data}   
	
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
	
    Click Tree Node On Site Manager    ${tree_node_server_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${Data}    
	
	##Check Trace##
	Open Trace Window    ${tree_node_panel_1}    ${01}    
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    6
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]   
    ...    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${module_1a_trace}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING_IMAGE}
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${module_1a_trace}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    connectionType=${TRACE_FIBER_PATCHING}
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]	objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}   
    ...    informationDevice=${port_list}[${i}]->${module_1a_trace}->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=6    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
	# 11. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the tasks from: 
	# _Panel 01// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 01// 01-06
	# _Panel 03// 01-06 to Server 01// 01-06
	Open Patching Window    ${tree_node_panel_3}    ${01}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Create Patching    patchFrom=${tree_node_panel_3}    patchTo=${tree_node_server_1}    
	...    portsFrom=${port_list}[${i}]    portsTo=${port_list}[${i}]    
	...    typeConnect=Disconnect
	...    clickNext=${False}
	Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_switch_1}    
	...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    
	...    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    
	...    typeConnect=Disconnect
	...    clickNext=${True}  
	Create Work Order    ${wo_name}
	
	# 12. Observe the port statuses, the propagated services and trace horizontal and vertical them
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledAvailableScheduled}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}

    Click Tree Node On Site Manager    ${tree_node_panel_3}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDPanelCabledAvailableScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service}    ${Data}   
	
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceAvailableScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
	
    Click Tree Node On Site Manager    ${tree_node_server_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledAvailableScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${Data} 
    
    ##Check Trace##
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_switch_1}    ${port_list}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str}   
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
        
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window

    Open Trace Window    ${tree_node_panel_1}   ${01}
    Select View Type On Trace    Scheduled
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1    
    ...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${module_1a_trace}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING_IMAGE}
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${module_1a_trace}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]	objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}   
    ...    informationDevice=${port_list}[${i}]->${module_1a_trace}->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    Current
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    6
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]   
    ...    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${module_1a_trace}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING_IMAGE}
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${module_1a_trace}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    connectionType=${TRACE_FIBER_PATCHING}
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]	objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}   
    ...    informationDevice=${port_list}[${i}]->${module_1a_trace}->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=6    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
	
	# 13. Complete the job above
	Open Work Order Queue Window
	Complete Work Order    ${wo_name}
	Close Work Order Queue
	
	# 14. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledAvailable}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}

    Click Tree Node On Site Manager    ${tree_node_panel_3}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDPanelCabledAvailable}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}   
	
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceAvailable}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]  
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
	
    Click Tree Node On Site Manager    ${tree_node_server_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledAvailable}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY}     
    
    ##Check Trace##
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_switch_1}    ${port_list}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str}   
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
        
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window

    Open Trace Window    ${tree_node_panel_1}   ${01}
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1    
    ...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${module_1a_trace}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING_IMAGE}
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${module_1a_trace}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]	objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}   
    ...    informationDevice=${port_list}[${i}]->${module_1a_trace}->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
SM-29808_SM-29832_09_Verify that the service is propagated and trace correctly in customer circuit: LC Switch -> cabled 6xLC to -> MPO12 Panel -> patched to -> MPO12 Panel -> cabled 6x LC to -> LC Panel -> patched to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-29808-29832_09
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}

    ##Set Variable##
    ${wo_name}    Set Variable    WO004
    ${tree_node_panel_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_1}
    ${tree_node_panel_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_2}
    ${tree_node_panel_3}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_3}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${SWITCH_NAME_1}
    ${tree_node_server_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${SERVER_NAME_1}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${pair_list}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    # 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add: 
	# _LC Switch 01 to Room 01
	# _MPO Panel 01, MPO Panel 02, LC Panel 03, LC Server 01 to Rack 001
	# 4. Set Data service for Switch 01// 01-06 directly
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
	Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
	Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${SWITCH_NAME_1}
	Add Network Equipment Port    ${tree_node_switch_1}    name=${01}    portType=${LC}     listChannel=${01}    
    ...    listServiceType=${Data}    quantity=6
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    name=${PANEL_NAME_1}
    ...    portType=${MPO}    quantity=2
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    name=${PANEL_NAME_3}
    ...    portType=${LC}
    Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${SERVER_NAME_1}    
	Add Device In Rack Port    ${tree_node_server_1}    name=${01}    portType=${LC}    quantity=6

	# 5. Cable from: 
	# _Panel 01// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 01// 01-06
	# _Panel 02// 01 (MPO12-6xLC)/1-1 -> 6-6  to Panel 03// MPO 01-06
	Open Cabling Window    ${tree_node_panel_1}    ${01}
	Create Cabling    cableFrom=${tree_node_panel_1}/${01}    cableTo=${tree_node_switch_1}    
	...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}
	...    portsTo=${01},${02},${03},${04},${05},${06}        
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
	Create Cabling    cableFrom=${tree_node_panel_2}/${01}    cableTo=${tree_node_panel_3}    
	...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}
	...    portsTo=${01},${02},${03},${04},${05},${06}        
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    Close Cabling Window
    
	# 6. Create the Add Patch job and DO NOT complete the job with the tasks from: 
	# _Panel 01// 01 (MPO12-MPO12) to Panel 02// 01
	# _Panel 03// 01-06 to Server 01// 01-06
	Open Patching Window    ${tree_node_panel_1}    ${01}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Create Patching    patchFrom=${tree_node_panel_3}    patchTo=${tree_node_server_1}    
	...    portsFrom=${port_list}[${i}]    portsTo=${port_list}[${i}]    clickNext=${False}
    Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_panel_2}    
	...    portsFrom=${01}    portsTo=${01}    
	...    mpoTab=${MPO12}    mpoType=${Mpo12_Mpo12}
	Create Work Order    ${wo_name}
	
	# 7. Observe the port statuses, the propagated services and trace horizontal and vertical them
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUseScheduled}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUseScheduled}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    1
	Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}

    Click Tree Node On Site Manager    ${tree_node_panel_3}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDPanelCabledInUseScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}   
	
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
	
    Click Tree Node On Site Manager    ${tree_node_server_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUseScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY}    
    
    ##Check Trace##
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]
	\    Select View Type On Trace    Current
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
    
    Open Trace Window    ${tree_node_panel_1}   ${01}
    Select View Type On Trace    Current
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]      
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    objectType=${TRACE_SWITCH_IMAGE}
    ...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]
    ...    objectPath=${tree_node_panel_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    Scheduled
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    6
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]      
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    objectType=${TRACE_SWITCH_IMAGE}
    ...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]
    ...    objectPath=${tree_node_panel_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_PATCHING}
    ...    scheduleIcon=${TRACE_SCHEDULED_IMAGE}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [ /${A1}]
    ...    objectPath=${tree_node_panel_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}
    ...    connectionType=${TRACE_FIBER_PATCHING}
    ...    scheduleIcon=${TRACE_SCHEDULED_IMAGE}
    ...    informationDevice=${port_list}[${i}]->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=6    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window

	# 8. Complete the job above
    Open Work Order Queue Window
	Complete Work Order    ${wo_name}
	Close Work Order Queue

	# 9. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}

    Click Tree Node On Site Manager    ${tree_node_panel_3}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDPanelCabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service}    ${Data}   
	
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
	
    Click Tree Node On Site Manager    ${tree_node_server_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${Data} 
    
    # ##Check Trace##
    Open Trace Window    ${tree_node_panel_1}    ${01}
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    6
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]      
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    objectType=${TRACE_SWITCH_IMAGE}
    ...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]
    ...    objectPath=${tree_node_panel_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_PATCHING}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [ /${A1}]
    ...    objectPath=${tree_node_panel_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}
    ...    connectionType=${TRACE_FIBER_PATCHING}
    ...    informationDevice=${port_list}[${i}]->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=6    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
	# 10. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the tasks from: 
	# _Panel 01// 01 (MPO12-MPO12) to Panel 02// 01
	# _Panel 03// 01-06 to Server 01// 01-06
	# _Panel 01// 01 (MPO12-MPO12) to Panel 02// 01
	# _Panel 03// 01-06 to Server 01// 01-06
	Open Patching Window    ${tree_node_panel_1}    ${01}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Create Patching    patchFrom=${tree_node_panel_3}    patchTo=${tree_node_server_1}    
	...    portsFrom=${port_list}[${i}]    portsTo=${port_list}[${i}]    clickNext=${False}
	...    typeConnect=Disconnect
    Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_panel_2}    
	...    portsFrom=${01}    portsTo=${01}    
	...    mpoTab=${MPO12}    mpoType=${Mpo12_Mpo12}
	...    typeConnect=Disconnect
	Create Work Order    ${wo_name}
	
    # 11. Observe the port statuses, the propagated services and trace horizontal and vertical them
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledAvailableScheduled}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledAvailableScheduled}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    1
	Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}

    Click Tree Node On Site Manager    ${tree_node_panel_3}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDPanelCabledAvailableScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service}    ${Data}   
	
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
	
    Click Tree Node On Site Manager    ${tree_node_server_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledAvailableScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${Data}   
    
    ## Check Trace##
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
    
    Open Trace Window    ${tree_node_panel_2}   ${01}
    Select View Type On Trace    Scheduled
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]
    ...    objectPath=${tree_node_panel_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}
    ...    informationDevice=${port_list}[${i}]->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_panel_1}   ${01}
    Select View Type On Trace    Scheduled
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]      
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    objectType=${TRACE_SWITCH_IMAGE}
    ...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]
    ...    objectPath=${tree_node_panel_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    Current
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    6
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]      
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    objectType=${TRACE_SWITCH_IMAGE}
    ...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]
    ...    objectPath=${tree_node_panel_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_PATCHING}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [ /${A1}]
    ...    objectPath=${tree_node_panel_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}
    ...    connectionType=${TRACE_FIBER_PATCHING}
    ...    informationDevice=${port_list}[${i}]->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=6    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
	# 12. Complete the job above
	Open Work Order Queue Window
	Complete Work Order    ${wo_name}
	Close Work Order Queue

	# 13. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledAvailable}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledAvailable}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
	Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}

    Click Tree Node On Site Manager    ${tree_node_panel_3}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDPanelCabledAvailable}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}   
	
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
	
    Click Tree Node On Site Manager    ${tree_node_server_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledAvailable}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY}
      
      ## Check Trace##
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
    
    Open Trace Window    ${tree_node_panel_2}   ${01}
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]
    ...    objectPath=${tree_node_panel_2}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}
    ...    informationDevice=${port_list}[${i}]->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_panel_1}   ${01}
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]      
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    objectType=${TRACE_SWITCH_IMAGE}
    ...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [ /${A1}]
    ...    objectPath=${tree_node_panel_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window

SM-29808_SM-29832_10_Verify that the service is propagated and trace correctly in customer circuit: LC Switch -> patched to -> MPO 12 Panel -> cabled to -> MPO12 Panel -> F2B 6xLC cabling -> LC Panel -> patched to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-29808-29832_10
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}

    ##Set Variable##
    ${wo_name}    Set Variable    WO005
    ${tree_node_panel_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_1}
    ${tree_node_panel_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_2}
    ${tree_node_panel_3}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_3}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${SWITCH_NAME_1}
    ${tree_node_server_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${SERVER_NAME_1}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${pair_list}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
    # 3. Add to Rack 001: 
    # _LC Switch 01
	# _MPO non-iPatch Panel 01
	# _MPO non-iPatch Panel 02
	# _LC Panel 03
	# _LC Server 01
	# 4. Set Data service for Switch 01// 01-06 directly
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
	Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
	Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${SWITCH_NAME_1}
	Add Network Equipment Port    ${tree_node_switch_1}    name=${01}    portType=${LC}     listChannel=${01}    
    ...    listServiceType=${Data}    quantity=6
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    name=${PANEL_NAME_1}
    ...    portType=${MPO}    quantity=2
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    name=${PANEL_NAME_3}
    ...    portType=${LC}
    Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${SERVER_NAME_1}    
	Add Device In Rack Port    ${tree_node_server_1}    name=${01}    portType=${LC}    quantity=6

	# 5. Cable from Panel 01// MPO 01 (MPO12-MPO12) to Panel 02// 01
	Open Cabling Window    ${tree_node_panel_1}    ${01}
	Create Cabling    cableFrom=${tree_node_panel_1}/${01}    cableTo=${tree_node_panel_2}    
	...    mpoTab=${MPO12}    mpoType=${Mpo12_Mpo12}
	...    portsTo=${01}
	Close Cabling Window
	      
	# 6. F2B cabling from Panel 02// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Panel 03// 01-06
	Open Front To Back Cabling Window    ${tree_node_panel_2}    ${01}
	Create Front To Back Cabling    cabFrom=${tree_node_panel_2}    cabTo=${tree_node_panel_3}    
	...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    
	...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
	Close Front To Back Cabling Window
	
	# 7. Create the Add Patch job and DO NOT complete the job with the tasks from:
	# _Panel 01//01 to Switch 01// 01-06
	# _Panel 03// 01-06 to Server 01// 01-06
	Open Patching Window    ${tree_node_panel_3}    ${01}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Create Patching    patchFrom=${tree_node_panel_3}    patchTo=${tree_node_server_1}    
	...    portsFrom=${port_list}[${i}]    portsTo=${port_list}[${i}]    clickNext=${False}
    Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_switch_1}    
	...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    
	...    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    
	...    clickNext=${True}  
	Create Work Order    ${wo_name}

	# 8. Observe the port statuses, the propagated services and trace horizontal and vertical them
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUseScheduled}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}

    Click Tree Node On Site Manager    ${tree_node_panel_3}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDPanelCabledInUseScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}   
	
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceInUseScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
	
    Click Tree Node On Site Manager    ${tree_node_server_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUseScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY}    

    # #Check  Trace#
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]
	\    Select View Type On Trace    Current
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
    
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_switch_1}    ${port_list}[${i}]
	\    Select View Type On Trace    Current
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str}   
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
	
    Open Trace Window    ${tree_node_panel_1}   ${01}
    Select View Type On Trace    Current
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1    
    ...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING_IMAGE}
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]	objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}   
    ...    informationDevice=${port_list}[${i}]->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    Scheduled
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    6
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]   
    ...    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    ...    scheduleIcon=${TRACE_SCHEDULED_IMAGE}
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING_IMAGE}
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    connectionType=${TRACE_FIBER_PATCHING}
    ...    scheduleIcon=${TRACE_SCHEDULED_IMAGE}
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]	objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}   
    ...    informationDevice=${port_list}[${i}]->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=6    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window

	# 9. Complete the job above
	Open Work Order Queue Window
	Complete Work Order    ${wo_name}
    Close Work Order Queue
    
	# 10. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}

    Click Tree Node On Site Manager    ${tree_node_panel_3}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDPanelCabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service}    ${Data}   
	
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
	
    Click Tree Node On Site Manager    ${tree_node_server_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${Data}    

    # ##Check  Trace##
    Open Trace Window    ${tree_node_panel_1}   ${01}
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    6
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]   
    ...    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING_IMAGE}
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    connectionType=${TRACE_FIBER_PATCHING}
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]	objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}   
    ...    informationDevice=${port_list}[${i}]->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=6    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window

	# 11. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the tasks from:
	# _Panel 01// 01-06 to Switch 01// 01-06
	# _Panel 03// 01-06 to Server 01// 01-06
	Open Patching Window    ${tree_node_panel_3}    ${01}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Create Patching    patchFrom=${tree_node_panel_3}    patchTo=${tree_node_server_1}    
	...    portsFrom=${port_list}[${i}]    portsTo=${port_list}[${i}]    clickNext=${False}
	...    typeConnect=Disconnect
    Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_switch_1}    
	...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    
	...    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    
	...    clickNext=${True}    
	...    typeConnect=Disconnect
	Create Work Order    ${wo_name}
	
	# 12. Observe the port statuses, the propagated services and trace horizontal and vertical them
	Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledAvailableScheduled}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${Data}

    Click Tree Node On Site Manager    ${tree_node_panel_3}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDPanelCabledAvailableScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service}    ${Data}   
	
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceAvailableScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
	
    Click Tree Node On Site Manager    ${tree_node_server_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledAvailableScheduled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${Data}    
	
    #Check  Trace#
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
    
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_switch_1}    ${port_list}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str}   
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
	
    Open Trace Window    ${tree_node_panel_1}   ${01}
    Select View Type On Trace    Scheduled
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1    
    ...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING_IMAGE}
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]	objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}   
    ...    informationDevice=${port_list}[${i}]->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    Current
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    6
    \    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str} [${pair_list}[${i}]]   
    ...    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING_IMAGE}
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    connectionType=${TRACE_FIBER_PATCHING}
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]	objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}   
    ...    informationDevice=${port_list}[${i}]->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=6    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
	
	# 13. Complete the job above
	Open Work Order Queue Window
	Complete Work Order    ${wo_name}
    Close Work Order Queue
    
	# 14. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    Click Tree Node On Site Manager    ${tree_node_panel_1}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledAvailable}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}

    Click Tree Node On Site Manager    ${tree_node_panel_3}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDPanelCabledAvailable}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}   
	
    Click Tree Node On Site Manager    ${tree_node_switch_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceAvailable}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Service},${port_list}[${i}]    ${EMPTY},${Data}    
	
    Click Tree Node On Site Manager    ${tree_node_server_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledAvailable}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
	\    Select Object On Content Table    ${port_list}[${i}]
    \    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY}    
	
    #Check  Trace#
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str}   
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
    
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_switch_1}    ${port_list}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    connectionType=${TRACE_ASSIGN}    
    ...    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}  
    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Check Trace Object On Site Manager    indexObject=2    objectPosition=${i_str}   
    ...    objectPath=${tree_node_switch_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
	
    Open Trace Window    ${tree_node_panel_1}   ${01}
    :FOR    ${i}     IN RANGE    0    len(${pair_list})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Total Trace On Site Manager    3
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1    
    ...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    ...    objectPath=${tree_node_panel_1}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [${A1}]    
    ...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING_IMAGE}
    ...    objectPath=${tree_node_panel_2}/${01}	objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}   
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${i_str} [ /${pair_list}[${i}]]    
    ...    objectPath=${tree_node_panel_3}/${port_list}[${i}]	objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}   
    ...    informationDevice=${port_list}[${i}]->${PANEL_NAME_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
      
SM-29808_SM-29832_18_Verify that user can create cabling MPO12-6xLC from InstaPatch Port (DM08) to LC Panel Port
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-29808-29832_18
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}

    ##Set Variable##
    ${module_1a}    Set Variable    Module 1A (DM08)
    ${mpo_01}    Set Variable    MPO 01
    ${no_path}    Set Variable    No Path
    ${tree_node_panel_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_1}/${module_1a}
    ${tree_node_panel_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_2}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${pair_list}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${port_list_dm08}    Create List    ${MPO1-01}    ${MPO1-02}    ${MPO1-03}    ${MPO1-04}
    ${position_list_dm08}    Create List    7    8    1    2
    
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _InstaPatch Panel 01 (DM08)
	# _LC Panel 02
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
	Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
	Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    
    ...    systimaxEquipmentType=${360 G2 Fiber Shelf (1U)}    name=${PANEL_NAME_1}    multiModule=Module 1A,True,LC 12 Port,DM08
	Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${PANEL_NAME_2}    portType=LC
	
	# 4. Cable from Panel 01// MPO 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Panel 02// 01-06
	Open Cabling Window    ${tree_node_panel_1}    ${MPO1-01}
	Create Cabling    cableFrom=${tree_node_panel_1}/${mpo_01}    cableTo=${tree_node_panel_2}    
	...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    
	...    portsTo=${01},${02},${03},${04},${05},${06}
	Close Cabling Window
	
    # 5. Observe the port icons, the port statuses and trace horizontal and vertical them
    Click Tree Node On Site Manager    ${tree_node_panel_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_dm08})
	\    Check Icon Object Exist On Content Pane    ${port_list_dm08}[${i}]    ${PortFDPanelCabledAvailable}
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_dm08}[${i}],${Available}    ${position_list_dm08}[${i}]
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDPanelCabledAvailable}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
    
    ## Check Trace##
    :FOR    ${i}     IN RANGE    0    len(${port_list_dm08})
    \    ${i_str}    Convert To String    ${i+1}
    \    Open Trace Window    ${tree_node_panel_2}    ${port_list}[${i}]   
    \    Check Total Trace On Site Manager    2
    \    Check Trace Object On Site Manager    indexObject=1   objectPosition=${i_str}    objectPath=${tree_node_panel_2}/${port_list}[${i}]    
    ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}
    ...    informationDevice=${port_list}[${i}]->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=2   objectPosition=${position_list_dm08}[${i}] (MPO1)    objectPath=${tree_node_panel_1}/${port_list_dm08}[${i}]    
    ...    objectType=${TRACE_DM08_PANEL_IMAGE}
    ...    informationDevice=${port_list_dm08}[${i}]->${module_1a}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}   
    \    Close Trace Window
     
    Open Trace Window    ${tree_node_panel_2}    ${05}   
    Check Total Trace On Site Manager    2
    Check Trace Object On Site Manager    indexObject=1   objectPosition=5 [ /5-5]    objectPath=${tree_node_panel_2}/${05}    
    ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}
    ...    informationDevice=${05}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Check Trace Object On Site Manager    indexObject=2   objectPosition=(MPO1)    
    ...    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_1}/Module 1A 
    ...    objectType=${TRACE_DM08_PANEL_IMAGE}
    ...    informationDevice=${no_path}->Module 1A->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}   
    Close Trace Window
    
    Open Trace Window    ${tree_node_panel_2}    ${06}   
    Check Total Trace On Site Manager    2
    Check Trace Object On Site Manager    indexObject=1   objectPosition=6 [ /6-6]    objectPath=${tree_node_panel_2}/${06}    
    ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}
    ...    informationDevice=${06}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Check Trace Object On Site Manager    indexObject=2   objectPosition=(MPO1)    
    ...    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_1}/Module 1A
    ...    objectType=${TRACE_DM08_PANEL_IMAGE}
    ...    informationDevice=${no_path}->Module 1A->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}   
    Close Trace Window

	# 6. Remove cabling from Panel 01// MPO 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Panel 02// 01-06
	Open Cabling Window    ${tree_node_panel_1}    ${MPO1-01}
	Create Cabling    cableFrom=${tree_node_panel_1}/${mpo_01}    cableTo=${tree_node_panel_2}    
	...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    
	...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    
	...    portsTo=${01},${02},${03},${04},${05},${06}
	...    typeConnect=DisConnect
	Close Cabling Window
	
	# 7. Observe the port icons, the port statuses and trace horizontal and vertical them
    Click Tree Node On Site Manager    ${tree_node_panel_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_dm08})
	\    Check Icon Object Exist On Content Pane    ${port_list_dm08}[${i}]    ${PortFDUncabledAvailable}
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_dm08}[${i}],${Available}    ${position_list_dm08}[${i}]
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledAvailable}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}
    
    ##Check Trace##
    :FOR    ${i}     IN RANGE    0    len(${port_list})
	\    ${i_str}    Convert To String    ${i+1}
	\    Open Trace Window    ${tree_node_panel_2}    ${port_list}[${i}]
	\    Select View Type On Trace    Current
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${i_str}   
    ...    objectPath=${tree_node_panel_2}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window
    
    :FOR    ${i}     IN RANGE    0    len(${port_list_dm08})
	\    Open Trace Window    ${tree_node_panel_1}    ${port_list_dm08}[${i}]
	\    Select View Type On Trace    Current
	\    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    indexObject=1    objectPosition=${position_list_dm08}[${i}]
    ...    objectPath=${tree_node_panel_1}/${port_list_dm08}[${i}]
    ...    informationDevice=${port_list_dm08}[${i}]->${module_1a}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window

SM-29808_SM-29832_19_Verify that the Trace window displays correctly for circuit: LC Switch -> DM08 -> MPO12 Panel -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-29808-29832_19
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}

    ##Set Variable##
    ${module_1a}    Set Variable    Module 1A (DM08)
    ${mpo_01}    Set Variable    MPO 01
    ${wo_name}    Set Variable    WO01
    ${no_path}    Set Variable    No Path
    ${tree_node_panel_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_1}/${module_1a}
    ${tree_node_panel_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${PANEL_NAME_2}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${pair_list}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${tree_node_switch_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${SWITCH_NAME_1}
    ${tree_node_server_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}/${SERVER_NAME_1}
    ${port_list_dm08}    Create List    ${MPO1-01}    ${MPO1-02}    ${MPO1-03}    ${MPO1-04}
    ${position_list_dm08}    Create List    7    8    1    2
    
    # 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add: 
	# _LC Switch 01
	# _Panel 01 (DM08)
	# _MPO Panel 02
	# _LC Server 01
	
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
	Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
	Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    
    ...    systimaxEquipmentType=${360 G2 Fiber Shelf (1U)}    name=${PANEL_NAME_1}    multiModule=Module 1A,True,LC 12 Port,DM08
	Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${PANEL_NAME_2}    portType=${MPO}
	Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${SWITCH_NAME_1}
	Add Network Equipment Port    ${tree_node_switch_1}    name=${01}    portType=${LC}     quantity=6    
    Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    ${SERVER_NAME_1}    
	Add Device In Rack Port    ${tree_node_server_1}    name=${01}    portType=${LC}    quantity=6

    # 4. Cable from Panel 01// MPO 01 (MPO12-MPO12) to Panel 02// 01
    Open Cabling Window    ${tree_node_panel_1}    ${MPO1-01}
    Create Cabling    cableFrom=${tree_node_panel_1}/${mpo_01}    cableTo=${tree_node_panel_2}    
    ...    portsTo=${01}
    Close Cabling Window
    
	# 5. Create Add Patch job and complete it from: 
	# _Panel 01// MPO1-01 -> 04 to Switch 01// 01-04
	# _Panel 02// 01 (MPO12-6xLC)/ 1-1 to 6-6 to Server 01// 01-06
	Open Patching Window    ${tree_node_panel_1}    ${MPO1-01}
	:FOR    ${i}     IN RANGE    0    len(${port_list_dm08})
	\    Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_switch_1}    
	...    portsFrom=${port_list_dm08}[${i}]    portsTo=${port_list}[${i}]
	...    clickNext=${False}
	Create Patching    patchFrom=${tree_node_panel_2}    patchTo=${tree_node_server_1}    
	...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}
	...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
	...    createWo=${False}
	
    # 6. Trace Switch 01// 01-06, Panel 01// MPO1-01 -> 04, Panel 02// 01 and Server 01// 01-06
    # 7. Observe the result    
    # Check Trace##
    Open Trace Window    ${tree_node_panel_2}    ${01}
    :FOR    ${i}     IN RANGE    0    len(${port_list_dm08})
    \    ${i_str}    Convert To String    ${i+1}
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}] 
    \    Check Total Trace On Site Manager    5
    \    Check Trace Object On Site Manager    indexObject=2   objectPosition=${i_str}    objectPath=${tree_node_switch_1}/${port_list}[${i}]    
    ...    objectType=${TRACE_SWITCH_IMAGE}    connectionType=${TRACE_FIBER_PATCHING}
    ...    informationDevice=${port_list}[${i}]->${SWITCH_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=3   objectPosition=${position_list_dm08}[${i}] (MPO1)    objectPath=${tree_node_panel_1}/${port_list_dm08}[${i}]    
    ...    objectType=${TRACE_DM08_PANEL_IMAGE}
    ...    informationDevice=${port_list_dm08}[${i}]->${module_1a}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager     indexObject=4    mpoType=12    objectPosition=1 [${A1}]
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Check Trace Object On Site Manager    indexObject=5    objectPosition=${i_str} [${pair_list}[${i}]] 
    ...    objectPath=${tree_node_server_1}/${port_list}[${i}]
    ...    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}  
    Close Trace Window
    
    Open Trace Window    ${tree_node_panel_2}    ${01}
    Select View Trace Tab On Site Manager    ${Pair 5}
    Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1   objectPosition=(MPO1)    objectPath=${tree_node_panel_1}
    ...    objectType=${TRACE_DM08_PANEL_IMAGE}
    ...    informationDevice=${no_path}->${module_1a}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Check Trace Object On Site Manager     indexObject=2    mpoType=12    objectPosition=1 [${A1}]
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Check Trace Object On Site Manager    indexObject=3    objectPosition=5 [${Pair 5}] 
    ...    objectPath=${tree_node_server_1}/${05}
    ...    informationDevice=${05}->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}  
    Close Trace Window
    
    Open Trace Window    ${tree_node_panel_2}    ${01}
    Select View Trace Tab On Site Manager    ${Pair 6}
    Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1   objectPosition=(MPO1)    objectPath=${tree_node_panel_1}
    ...    objectType=${TRACE_DM08_PANEL_IMAGE}
    ...    informationDevice=${no_path}->${module_1a}->${PANEL_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Check Trace Object On Site Manager     indexObject=2    mpoType=12    objectPosition=1 [${A1}]
    ...    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ...    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    ...    informationDevice=${01}->${PANEL_NAME_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Check Trace Object On Site Manager    indexObject=3    objectPosition=6 [${Pair 6}] 
    ...    objectPath=${tree_node_server_1}/${06}
    ...    informationDevice=${06}->${SERVER_NAME_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}  
    Close Trace Window
    