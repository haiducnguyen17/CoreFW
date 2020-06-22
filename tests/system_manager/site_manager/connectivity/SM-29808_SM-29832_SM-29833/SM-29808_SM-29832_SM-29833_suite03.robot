*** Settings ***
Resource    ../../../../../resources/constants.robot       
Resource    ../../../../../resources/icons_constants.robot  
Resource    ../../../../../resources/bug_report.robot

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
${FLOOR_2}    Floor 02
${FLOOR_3}    Floor 03 
${ROOM_NAME}    Room 01
${RACK_POSITION}    1:1 ${RACK_NAME}
${RACK_GROUP_NAME}    Rack Group 01
${RACK_NAME}    Rack 001
${SWITCH_1}    Switch 01
${SWITCH_2}    Switch 02
${SWITCH_3}    Blade 1 BX630 F1R5 cabina 1
${SWITCH_4}    Blade 2 BX630 F1R5 cabina 1
${SERVER_1}    Server 01
${SERVER_2}    Server 02
${CARD_1}    Card 01
${CARD_2}    Card 02
${FACEPLATE_NAME}    Faceplate 01
${MEDIA_CONVERTER_NAME}    MC 01
${PANEL_1}    Panel 01
${PANEL_2}    Panel 02
${PANEL_3}    Panel 03
${PANEL_4}    Panel 04
${GBIC_SLOT_1}    GBIC Slot 01
${TRAY_NAME}    Tray 01
${BLADE_SERVER_NAME}    Blade Server 01
${ENCLOSURE_NAME}    Enclosure 01
${ZONE}    1
${POSITION}    1

*** Test Cases ***
SM-29808_SM-29832_SM-29833_11-Verify that the service is propagated and trace correctly in circuit: LC Switch -> cabled 6xLC to -> MPO12 Panel -> patched 6xLC to -> LC Panel -> cabled to -> LC Faceplate
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_11
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
   [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}

    ${tree_node_room}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}    

    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
	Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    # 3. Add: 
    # _LC Switch 01, LC Faceplate 01 to Room 01
    # _MPO Panel 01, LC Panel 02 to Rack 001
    # 4. Set Data service for Switch 01// 01 directly
    Add Network Equipment    ${tree_node_room}    ${SWITCH_1}
    Add Network Equipment Port    ${tree_node_room}/${SWITCH_1}    ${01}    ${LC}    listChannel=${01}    listServiceType=${Data}    
    Add Faceplate    ${tree_node_room}    ${FACEPLATE_NAME}    ${LC}    
    Add Generic Panel    ${tree_node_rack}    ${PANEL_1}    portType=${MPO}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_2}    portType=${LC}
    # 5. Cable from: 
    # _Panel 01// 01 (MPO12-6xLC)/ 1-1 to Switch 01// 01
    # _Panel 02// 01 to Faceplate 01// 01
    Open Cabling Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Create Cabling    Connect    ${tree_node_rack}/${PANEL_1}/${01}    ${tree_node_room}/${SWITCH_1}    ${MPO12}    ${Mpo12_6xLC_EB}    ${Pair 1}    ${01}    
    Create Cabling    Connect    ${tree_node_rack}/${PANEL_2}/${01}    ${tree_node_room}/${FACEPLATE_NAME}    portsTo=${01}
    Close Cabling Window        
    # 6. Create the Add Patch job and DO NOT complete the job with the task from Panel 01// 01 (MPO12-6xLC)/ 1-1 to Panel 02// 01
    Open Patching Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Create Patching    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${PANEL_2}    ${01}    ${01}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1}
    Create Work Order    ${building_name}    
    # 7. Observe the port statuses, the propagated services and trace horizontal and vertical them
    ${tree_check_1}    Create List    ${tree_node_room}/${FACEPLATE_NAME}    ${tree_node_room}/${SWITCH_1}    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${PANEL_2}    
    ${port_icon_1}    Create List    ${PortFDCabledInUseScheduled}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledInUseScheduled}    ${PortFDCabledInUseScheduled}
    ${service_name_1}    Create List    ${Service}    ${01}    ${Service}    ${Service}    
    ${service_1}    Create List    ${EMPTY}    ${Data}    ${Data}    ${EMPTY}    
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${01}    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_1}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_1}[${i}]    
    
    ${object_index_1}    Create List    1    2
    ${object_position_1}    Create List    1    1
    ${object_path_1}    Create List    ${tree_node_rack}/${PANEL_2}/${01}    ${tree_node_room}/${FACEPLATE_NAME}/${01}
    ${object_type_1}    Create List    ${TRACE_GENERIC_LC_PANEL_IMAGE}    ${TRACE_LC_FACEPLATE_IMAGE}
    ${port_icon_1}    Create List    ${PortFDCabledInUseScheduled}    ${PortFDCabledInUseScheduled}
    ${connection_type_1}    Create List    ${TRACE_FIBER_BACK_TO_BACK_CABLING}    ${None}
    ${information_device_1}    Create List    ${01}->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${01}->${FACEPLATE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}      
    
    Open Trace Window    ${tree_node_room}/${FACEPLATE_NAME}    ${01}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_1}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_1}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_1}[${i}]
    
    ${object_index_2}    Create List    1    2    3    4    5
    ${object_position_2}    Create List    ${EMPTY}    1 [${Pair 1}]    1 [${A1}/${A1}]    1 [${Pair 1}]    1
    ${object_path_2}    Create List    ${Config}: /${VLAN}: /${Service}: ${Data}    ${tree_node_room}/${SWITCH_1}/${01}    ${tree_node_rack}/${PANEL_1}/${01}    ${tree_node_rack}/${PANEL_2}/${01}    ${tree_node_room}/${FACEPLATE_NAME}/${01}
    ${object_type_2}    Create List    ${Service}    ${TRACE_SWITCH_IMAGE}    ${TRACE_GENERIC_MPO_PANEL_IMAGE}    ${TRACE_GENERIC_LC_PANEL_IMAGE}    ${TRACE_LC_FACEPLATE_IMAGE}
    ${port_icon_2}    Create List    ${None}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledInUseScheduled}    ${PortFDCabledInUseScheduled}    ${PortFDCabledInUseScheduled}
    ${connection_type_2}    Create List    ${TRACE_ASSIGN}    ${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    ${TRACE_MPO12_6X_LC_EB_PATCHING}    ${TRACE_FIBER_BACK_TO_BACK_CABLING}    ${None}
    ${schedule_icon_2}    Create List    ${None}    ${None}    ${TRACE_SCHEDULED_WORK_TIME_PERIOD}    ${None}    ${None}    
    ${information_device_2}    Create List    ${Service}:->${Data}->${VLAN}:->${Config}:    ${01}->${SWITCH_1}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${01}->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${01}->${FACEPLATE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    5
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2}[${i}]
    Close Trace Window
    
    ${object_index_3}    Create List    1    2    3
    ${object_position_3}    Create List    ${EMPTY}    1 [${Pair 1}]    1 [ /${A1}]    
    ${object_path_3}    Create List    ${Config}: /${VLAN}: /${Service}: ${Data}    ${tree_node_room}/${SWITCH_1}/${01}    ${tree_node_rack}/${PANEL_1}/${01}
    ${object_type_3}    Create List    ${Service}    ${TRACE_SWITCH_IMAGE}    ${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ${port_icon_3}    Create List    ${None}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledInUseScheduled}
    ${connection_type_3}    Create List    ${TRACE_ASSIGN}    ${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    ${None}
    ${information_device_3}    Create List    ${Service}:->${Data}->${VLAN}:->${Config}:    ${01}->${SWITCH_1}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}      
    
    Open Trace Window    ${tree_node_room}/${SWITCH_1}    ${01}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3}[${i}]    objectPath=${object_path_3}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_3}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3}[${i}]              
    
    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    5
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2}[${i}]
    Close Trace Window
    
    ${pair_tab}    Create List    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Trace Tab On Site Manager    ${Pair 1}
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3}[${i}]    objectPath=${object_path_3}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_3}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3}[${i}]    
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab}) 
    \    Select View Trace Tab On Site Manager    ${pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    objectPosition=1 [ /${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledInUseScheduled}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    ${Scheduled}
    Select View Trace Tab On Site Manager    ${Pair 1}
    Check Total Trace On Site Manager    5
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2}[${i}]
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab}) 
    \    Select View Trace Tab On Site Manager    ${pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    mpoType=${12}    objectPosition=1 [ /${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledInUseScheduled}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${01}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_1}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_1}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_1}[${i}]
    
    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    5
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2}[${i}]
    Close Trace Window
    # 8. Complete the job above
    Open Work Order Queue Window    
    Complete Work Order    ${building_name}
    Close Work Order Queue
    # 9. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    ${port_icon_4}    Create List    ${PortFDCabledInUse}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledInUse}    ${PortFDCabledInUse}    
    ${service_2}    Create List    ${Data}    ${Data}    ${Data}    ${Data}    
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${01}    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_4}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_2}[${i}] 
    
    ${schedule_icon_4}    Create List    ${None}    ${None}    ${None}    ${None}    ${None}
    ${port_icon_5}    Create List    ${None}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledInUse}    ${PortFDCabledInUse}    ${PortFDCabledInUse}

    Open Trace Window    ${tree_node_room}/${FACEPLATE_NAME}    ${01}
    Check Total Trace On Site Manager    5
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_5}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_room}/${SWITCH_1}    ${01}
    Check Total Trace On Site Manager    5
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_5}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Trace Tab On Site Manager    ${Pair 1}
    Check Total Trace On Site Manager    5
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_5}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2}[${i}]

    Report Bug    ${SM_30324}    

    :FOR    ${i}    IN RANGE    0    len(${pair_tab}) 
    \    Select View Trace Tab On Site Manager    ${pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    objectPosition=1 [ /${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${01}
    Check Total Trace On Site Manager    5
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_5}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2}[${i}]
    Close Trace Window
    # 10. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the task from Panel 01// 01 (MPO12-6xLC)/ 1-1 to Panel 02// 01
    Open Patching Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Create Patching    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${PANEL_2}    ${01}    ${01}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1}
    Create Work Order    ${building_name}    
    # 11. Observe the port statuses, the propagated services and trace horizontal and vertical them
    ${port_icon_6}    Create List    ${PortFDCabledAvailableScheduled}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledAvailableScheduled}    ${PortFDCabledAvailableScheduled}
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${01}    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_2}[${i}]    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_6}[${i}]    
    
    ${port_icon_7}    Create List    ${None}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledAvailableScheduled}    ${PortFDCabledAvailableScheduled}    ${PortFDCabledAvailableScheduled}

    Open Trace Window    ${tree_node_room}/${FACEPLATE_NAME}    ${01}
    Check Total Trace On Site Manager    5
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_7}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2}[${i}]
    
    ${port_icon_7_1}    Create List    ${PortFDCabledAvailableScheduled}    ${PortFDCabledAvailableScheduled}    

    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_1}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_7_1}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_1}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_room}/${SWITCH_1}    ${01}
    Check Total Trace On Site Manager    5
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_7}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2}[${i}]              
    
    ${port_icon_7_2}    Create List    ${None}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledAvailableScheduled}

    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3}[${i}]    objectPath=${object_path_3}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_7_2}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Trace Tab On Site Manager    ${Pair 1}
    Check Total Trace On Site Manager    5
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_7}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2}[${i}]
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab}) 
    \    Select View Trace Tab On Site Manager    ${pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    objectPosition=1 [ /${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledAvailableScheduled}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    ${Scheduled}
    Select View Trace Tab On Site Manager    ${Pair 1}
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3}[${i}]    objectPath=${object_path_3}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_7_2}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3}[${i}]    
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab}) 
    \    Select View Trace Tab On Site Manager    ${pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    objectPosition=1 [ /${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledAvailableScheduled}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${01}
    Check Total Trace On Site Manager    5
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_7}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2}[${i}]
    
    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_1}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_7_1}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_1}[${i}]
    Close Trace Window
    # 12. Complete the job above
    Open Work Order Queue Window    
    Complete Work Order    ${building_name}
    Close Work Order Queue
    # 13. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    ${port_icon_8_1}    Create List    ${PortFDCabledAvailable}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledAvailable}    ${PortFDCabledAvailable}
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${01}    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_8_1}[${i}]     
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_1}[${i}]   
    
    ${port_icon_8_2}    Create List    ${PortFDCabledAvailable}    ${PortFDCabledAvailable}

    Open Trace Window    ${tree_node_room}/${FACEPLATE_NAME}    ${01}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_1}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_8_2}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_1}[${i}]
    Close Trace Window
    
    ${port_icon_8_3}    Create List    ${None}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledAvailable}

    Open Trace Window    ${tree_node_room}/${SWITCH_1}    ${01}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3}[${i}]    objectPath=${object_path_3}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_8_3}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Trace Tab On Site Manager    ${Pair 1}
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3}[${i}]    objectPath=${object_path_3}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_8_3}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3}[${i}]    
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab}) 
    \    Select View Trace Tab On Site Manager    ${pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    objectPosition=1 [ /${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledAvailable}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${01}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_1}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_8_2}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_1}[${i}]
    Close Trace Window
    
SM-29808_SM-29832_SM-29833_12_Verify that the service is propagated and trace correctly in circuit: LC Switch -> cabled 6xLC-EB to -> MPO12 Panel -> patched 6xLC-EB to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_12
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}
    
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}
    
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
	Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    # 3. Add to Rack 001: 
    # _LC Switch 01
    # _MPO Panel 01
    # _LC Server 01
    # 4. Set Data service for Switch 01// 01 directly
    Add Network Equipment    ${tree_node_rack}    ${SWITCH_1}
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_1}    ${01}    ${LC}    listChannel=${01}    listServiceType=${Data}    
    Add Generic Panel    ${tree_node_rack}    ${PANEL_1}    portType=${MPO}
    Add Device In Rack    ${tree_node_rack}    ${SERVER_1}
    Add Device In Rack Port    ${tree_node_rack}/${SERVER_1}    ${01}    ${LC}
    # 5. Cable from Panel 01// 01 (MPO12-6xLC-EB)/Pair 1 to Switch 01// 01
    Open Cabling Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Create Cabling    Connect    ${tree_node_rack}/${PANEL_1}/${01}    ${tree_node_rack}/${SWITCH_1}    ${MPO12}    ${Mpo12_6xLC_EB}    ${Pair 1}    ${01}    
    Close Cabling Window
    # 6. Create the Add Patch job and DO NOT complete the job with the task from Panel 01// 01 (MPO12-6xLC-EB)/ Pair 1 to Server 01// 01
    Open Patching Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Create Patching    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${SERVER_1}    ${01}    ${01}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1}
    Create Work Order    ${building_name}
    # 7. Observe the port statuses, the propagated services and trace horizontal and vertical them
    ${tree_check_1}    Create List    ${tree_node_rack}/${SWITCH_1}    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${SERVER_1}    
    ${port_icon_1}    Create List    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledInUseScheduled}    ${PortFDUncabledInUseScheduled}
    ${service_name_1}    Create List    ${01}    ${Service}   ${Current Service}    
    ${service_1}    Create List    ${Data}    ${Data}    ${EMPTY}    
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${01}    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_1}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_1}[${i}]    
    
    ${object_index_2}    Create List    1    2    3    4
    ${object_position_2}    Create List    ${EMPTY}    1 [${Pair 1}]    1 [${A1}/${A1}]    1 [${Pair 1}]
    ${object_path_2}    Create List    ${Config}: /${VLAN}: /${Service}: ${Data}    ${tree_node_rack}/${SWITCH_1}/${01}    ${tree_node_rack}/${PANEL_1}/${01}    ${tree_node_rack}/${SERVER_1}/${01}
    ${object_type_2}    Create List    ${Service}    ${TRACE_SWITCH_IMAGE}    ${TRACE_GENERIC_MPO_PANEL_IMAGE}    ${TRACE_SERVER_FIBER_IMAGE}
    ${port_icon_2}    Create List    ${None}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledInUseScheduled}    ${PortFDUncabledInUseScheduled}
    ${connection_type_2}    Create List    ${TRACE_ASSIGN}    ${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    ${TRACE_MPO12_6X_LC_EB_PATCHING}    ${None}
    ${schedule_icon_2}    Create List    ${None}    ${None}    ${TRACE_SCHEDULED_WORK_TIME_PERIOD}    ${None}    
    ${information_device_2}    Create List    ${Service}:->${Data}->${VLAN}:->${Config}:    ${01}->${SWITCH_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${01}->${SERVER_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    ${object_index_3}    Create List    1    2    3
    ${object_position_3}    Create List    ${EMPTY}    1 [${Pair 1}]    1 [ /${A1}]    
    ${object_path_3}    Create List    ${Config}: /${VLAN}: /${Service}: ${Data}    ${tree_node_rack}/${SWITCH_1}/${01}    ${tree_node_rack}/${PANEL_1}/${01}
    ${object_type_3}    Create List    ${Service}    ${TRACE_SWITCH_IMAGE}    ${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ${port_icon_3}    Create List    ${None}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledInUseScheduled}
    ${connection_type_3}    Create List    ${TRACE_ASSIGN}    ${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    ${None}
    ${information_device_3}    Create List    ${Service}:->${Data}->${VLAN}:->${Config}:    ${01}->${SWITCH_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}      
    
    Open Trace Window    ${tree_node_rack}/${SWITCH_1}    ${01}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3}[${i}]    objectPath=${object_path_3}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_3}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3}[${i}]              
    
    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2}[${i}]
    Close Trace Window
    
    ${pair_tab}    Create List    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Trace Tab On Site Manager    ${Pair 1}
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3}[${i}]    objectPath=${object_path_3}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_3}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3}[${i}]    
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab}) 
    \    Select View Trace Tab On Site Manager    ${pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    objectPosition=1 [ /${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledInUseScheduled}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    ${Scheduled}
    Select View Trace Tab On Site Manager    ${Pair 1}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2}[${i}]
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab}) 
    \    Select View Trace Tab On Site Manager    ${pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    objectPosition=1 [ /${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledInUseScheduled}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${SERVER_1}    ${01}
    Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    1    objectPosition=1    objectPath=${tree_node_rack}/${SERVER_1}/${01}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledInUseScheduled}    informationDevice=${01}->${SERVER_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2}[${i}]
    Close Trace Window
    # 8. Complete the job above
    Open Work Order Queue Window    
    Complete Work Order    ${building_name}
    Close Work Order Queue
    # 9. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    ${port_icon_4}    Create List    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledInUse}    ${PortFDUncabledInUse}
    ${service_2}        Create List    ${Data}    ${Data}    ${Data}
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${01}    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_4}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_2}[${i}] 
   
    ${schedule_icon_2}    Create List    ${None}    ${None}    ${None}    ${None}
    ${port_icon_4_1}    Create List    ${None}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledInUse}    ${PortFDUncabledInUse}
    
    Open Trace Window    ${tree_node_rack}/${SWITCH_1}    ${01}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Trace Tab On Site Manager    ${Pair 1}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2}[${i}]
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab}) 
    \    Select View Trace Tab On Site Manager    ${pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    objectPosition=1 [ /${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledInUseScheduled}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${SERVER_1}    ${01}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2}[${i}]
    Close Trace Window
    # 10. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the task from Panel 01// 01 (MPO12-6xLC-EB)/ Pair 1 to Server 01// 01
    Open Patching Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Create Patching    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${SERVER_1}    ${01}    ${01}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1}
    Create Work Order    ${building_name}
    # 11. Observe the port statuses, the propagated services and trace horizontal and vertical them
    ${port_icon_5}    Create List    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledAvailableScheduled}    ${PortFDUncabledAvailableScheduled}    
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${01}    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_5}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_2}[${i}]    
    
    ${port_icon_5_1}    Create List    ${None}    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledAvailableScheduled}    ${PortFDUncabledAvailableScheduled}

    Open Trace Window    ${tree_node_rack}/${SWITCH_1}    ${01}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_5_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2}[${i}]              
    
    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3}[${i}]    objectPath=${object_path_3}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_5_1}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Trace Tab On Site Manager    ${Pair 1}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_5_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2}[${i}]
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab}) 
    \    Select View Trace Tab On Site Manager    ${pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    objectPosition=1 [ /${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledInUseScheduled}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    ${Scheduled}
    Select View Trace Tab On Site Manager    ${Pair 1}
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3}[${i}]    objectPath=${object_path_3}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_5_1}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3}[${i}]    
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab}) 
    \    Select View Trace Tab On Site Manager    ${pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    objectPosition=1 [ /${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledAvailableScheduled}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${SERVER_1}    ${01}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2}[${i}]    objectPath=${object_path_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_5_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2}[${i}]
    
    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    1    objectPosition=1    objectPath=${tree_node_rack}/${SERVER_1}/${01}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledAvailableScheduled}    informationDevice=${01}->${SERVER_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    # 12. Complete the job above
    Open Work Order Queue Window    
    Complete Work Order    ${building_name}
    Close Work Order Queue
    # 13. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    ${port_icon_6}    Create List    ${PortNEFDServiceCabled}    ${PortMPOServiceCabledAvailable}    ${PortFDUncabledAvailable}    
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${01}    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_5}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_1}[${i}]    
    
    Open Trace Window    ${tree_node_rack}/${SWITCH_1}    ${01}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3}[${i}]    objectPath=${object_path_3}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_3}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Trace Tab On Site Manager    ${Pair 1}
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3}[${i}]    objectPath=${object_path_3}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_3}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3}[${i}]    
    
    Report Bug    ${SM_30324}

    :FOR    ${i}    IN RANGE    0    len(${pair_tab}) 
    \    Select View Trace Tab On Site Manager    ${pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    objectPosition=1 [ /${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledInUseScheduled}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${SERVER_1}    ${01}
    Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    1    objectPosition=1    objectPath=${tree_node_rack}/${SERVER_1}/${01}    objectType=${TRACE_SERVER_FIBER_IMAGE}    
    ...    portIcon=${PortFDUncabledAvailable}    informationDevice=${01}->${SERVER_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window

SM-29808_SM-29832_SM-29833_13_Verify that the service is propagated and trace correctly in circuit: LC Switch -> patched to -> LC Panel -> cabled to -> Splice - Splice -> cabled to -> LC Panel -> patched 6xLC-EB to -> MPO Panel
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_13
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}

    ${tree_node_room}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}
    
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
	Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    # 3. Add: 
    # _LC Splice Enclosure 01/ Tray 01 to Room 01
    # _LC Switch 01, LC Panel 01, LC Panel 02, MPO Panel 03 to Rack 001
    # 4. Set Data service for Switch 01// 01 directly
    Add Splice Enclosure    ${tree_node_room}    ${ENCLOSURE_NAME}
    Add Splice Tray    ${tree_node_room}/${ENCLOSURE_NAME}    ${TRAY_NAME}    spliceType=${Fiber}
    Add Network Equipment    ${tree_node_rack}    ${SWITCH_1}
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_1}    ${01}    ${LC}    listChannel=${01}    listServiceType=${Data}    
    Add Generic Panel    ${tree_node_rack}    ${PANEL_1}    portType=${LC}    quantity=2    
    Add Generic Panel    ${tree_node_rack}    ${PANEL_3}    portType=${MPO}      
    # 5. Cable from: 
    # _Panel 01// 01 to Splice Enclosure 01// 01 In & 02 In
    # _Panel 02// 01 to Splice Enclosure 01// 01 Out & 02 Out
    Open Cabling Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Create Cabling    Connect    ${tree_node_rack}/${PANEL_1}/${01}    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}    portsTo=01 In    
    Create Cabling    Connect    ${tree_node_rack}/${PANEL_2}/${01}    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}    portsTo=01 Out
    Close Cabling Window
    # 6. Create the Add Patch job and DO NOT complete the job with the tasks from: 
    # _Switch 01// 01 to Panel 01// 01
    # _Panel 03// 01 (MPO12-6xLC EB)/ Pair 1 to Panel 02// 01
    Open Patching Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Create Patching    ${tree_node_rack}/${SWITCH_1}    ${tree_node_rack}/${PANEL_1}   ${01}    ${01}    clickNext=${False}        
    Create Patching    ${tree_node_rack}/${PANEL_3}    ${tree_node_rack}/${PANEL_2}   ${01}    ${01}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1}
    Create Work Order    ${building_name}
    # 7. Observe the port status, the propagated services and trace horizontal and vertical them
    ${tree_check_1}    Create List    ${tree_node_rack}/${SWITCH_1}    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${PANEL_2}    ${tree_node_rack}/${PANEL_3}    
    ${port_icon_1}    Create List    ${PortNEFDServiceInUseScheduled}    ${PortFDPanelCabledInUseScheduled}    ${PortFDPanelCabledInUseScheduled}    ${PortMPOUncabledInUseScheduled}
    ${service_name_1}    Create List    ${01}    ${Service}    ${Service}    ${Service}    
    ${service_1}    Create List    ${Data}    ${EMPTY}    ${EMPTY}    ${EMPTY}    
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${01}    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_1}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_1}[${i}]    
    
    ${object_index_1}    Create List    1    2
    ${object_position_1}    Create List    ${EMPTY}    1
    ${object_path_1_1}    Create List    ${Config}: /${VLAN}: /${Service}: ${Data}    ${tree_node_rack}/${SWITCH_1}/${01} B
    ${object_path_1_2}    Create List    ${Config}: /${VLAN}: /${Service}: ${Data}    ${tree_node_rack}/${SWITCH_1}/${01} A
    ${object_type_1}    Create List    ${Service}    ${TRACE_SWITCH_IMAGE}
    ${port_icon_1_1}    Create List    ${None}    ${PortFDServiceCabledBInUseScheduled}
    ${port_icon_1_2}    Create List    ${None}    ${PortFDServiceCabledAInUseScheduled}
    ${connection_type_1}    Create List    ${TRACE_ASSIGN}    ${None}
    ${information_device_1_1}    Create List    ${Service}:->${Data}->${VLAN}:->${Config}:    ${01} B->${SWITCH_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ${information_device_1_2}    Create List    ${Service}:->${Data}->${VLAN}:->${Config}:    ${01} A->${SWITCH_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}      
    
    Open Trace Window    ${tree_node_rack}/${SWITCH_1}    ${01}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_1_1}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_1_1}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_1_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_1_2}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_1_2}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_1_2}[${i}]
    
    ${object_index_2}    Create List    1    2    3    4    5    6    7
    ${object_position_2_1}    Create List    ${EMPTY}    1    1    1    2    1 [${Pair 1}]    1 [${A1}]
    ${object_position_2_2}    Create List    ${EMPTY}    1    1    3    4    1 [${Pair 1}]    1 [${A1}]
    ${object_path_2_1}    Create List    ${Config}: /${VLAN}: /${Service}: ${Data}    ${tree_node_rack}/${SWITCH_1}/${01} B    ${tree_node_rack}/${PANEL_1}/${01} A    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}/${01} In    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}/${01} Out    ${tree_node_rack}/${PANEL_2}/${01} A    ${tree_node_rack}/${PANEL_3}/${01}
    ${object_path_2_2}    Create List    ${Config}: /${VLAN}: /${Service}: ${Data}    ${tree_node_rack}/${SWITCH_1}/${01} A    ${tree_node_rack}/${PANEL_1}/${01} B    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}/${02} In    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}/${02} Out    ${tree_node_rack}/${PANEL_2}/${01} B    ${tree_node_rack}/${PANEL_3}/${01}
    ${object_type_2}    Create List    ${Service}    ${TRACE_SWITCH_IMAGE}    ${TRACE_GENERIC_LC_PANEL_IMAGE}    ${TRACE_SPLICE_ENCLOSURE_IMAGE}    ${TRACE_SPLICE_ENCLOSURE_IMAGE}    ${TRACE_GENERIC_LC_PANEL_IMAGE}    ${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ${port_icon_2_1}    Create List    ${None}    ${PortFDServiceCabledBInUseScheduled}    ${PortFDPanelCabledAInUseScheduled}    ${SpliceFCabled}    ${SpliceFCabled}    ${PortFDPanelCabledAInUseScheduled}    ${PortMPOUncabledInUseScheduled}
    ${port_icon_2_2}    Create List    ${None}    ${PortFDServiceCabledAInUseScheduled}    ${PortFDPanelCabledBInUseScheduled}    ${SpliceFCabled}    ${SpliceFCabled}    ${PortFDPanelCabledBInUseScheduled}    ${PortMPOUncabledInUseScheduled}
    ${connection_type_2}    Create List    ${TRACE_ASSIGN}    ${TRACE_FIBER_PATCHING}    ${TRACE_FIBER_BACK_TO_BACK_CABLING}    ${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}        ${TRACE_FIBER_BACK_TO_BACK_CABLING}    ${TRACE_LC_6X_MPO12_EB_PATCHING}    ${None}
    ${schedule_icon_2}    Create List    ${None}    ${TRACE_SCHEDULED_WORK_TIME_PERIOD}    ${None}    ${None}    ${None}    ${TRACE_SCHEDULED_WORK_TIME_PERIOD}    ${None}    
    ${information_device_2_1}    Create List    ${Service}:->${Data}->${VLAN}:->${Config}:    ${01} B->${SWITCH_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${01} A->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${01} In->${TRAY_NAME}->${ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${01} Out->${TRAY_NAME}->${ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${01} A->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${01}->${PANEL_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ${information_device_2_2}    Create List    ${Service}:->${Data}->${VLAN}:->${Config}:    ${01} A->${SWITCH_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${01} B->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${02} In->${TRAY_NAME}->${ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${02} Out->${TRAY_NAME}->${ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${01} B->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${01}->${PANEL_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    ${Scheduled}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2_2}[${i}]
    Close Trace Window
    
    ${object_index_3}    Create List    1    2    3    4
    ${object_position_3_1}    Create List    1    3    4    1
    ${object_position_3_2}    Create List    1    1    2    1    
    ${object_path_3_1}    Create List    ${tree_node_rack}/${PANEL_1}/${01} B    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}/${02} In    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}/${02} Out    ${tree_node_rack}/${PANEL_2}/${01} B    
    ${object_path_3_2}    Create List    ${tree_node_rack}/${PANEL_1}/${01} A    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}/${01} In    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}/${01} Out    ${tree_node_rack}/${PANEL_2}/${01} A
    ${object_type_3}    Create List    ${TRACE_GENERIC_LC_PANEL_IMAGE}    ${TRACE_SPLICE_ENCLOSURE_IMAGE}    ${TRACE_SPLICE_ENCLOSURE_IMAGE}    ${TRACE_GENERIC_LC_PANEL_IMAGE}
    ${port_icon_3_1}    Create List    ${PortFDPanelCabledBInUseScheduled}    ${SpliceFCabled}    ${SpliceFCabled}    ${PortFDPanelCabledBInUseScheduled}
    ${port_icon_3_2}    Create List    ${PortFDPanelCabledAInUseScheduled}    ${SpliceFCabled}    ${SpliceFCabled}    ${PortFDPanelCabledAInUseScheduled}
    ${connection_type_3}    Create List    ${TRACE_FIBER_BACK_TO_BACK_CABLING}    ${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}        ${TRACE_FIBER_BACK_TO_BACK_CABLING}    ${None}
    ${information_device_3_1}    Create List    ${01} B->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${02} In->${TRAY_NAME}->${ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${02} Out->${TRAY_NAME}->${ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${01} B->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ${information_device_3_2}    Create List    ${01} A->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${01} In->${TRAY_NAME}->${ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${01} Out->${TRAY_NAME}->${ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${01} A->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     
    
    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3_1}[${i}]    objectPath=${object_path_3_1}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_3_1}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3_2}[${i}]    objectPath=${object_path_3_2}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_3_2}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3_2}[${i}]              
    
    Select View Type On Trace    ${Scheduled}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2_1}[${i}]
    Close Trace Window
    
    ${object_position_3_3}    Create List    1    4    3    1
    ${object_position_3_4}    Create List    1    2    1    1    
    ${object_path_3_3}    Create List    ${tree_node_rack}/${PANEL_2}/${01} B    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}/${02} Out    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}/${02} In    ${tree_node_rack}/${PANEL_1}/${01} B    
    ${object_path_3_4}    Create List    ${tree_node_rack}/${PANEL_2}/${01} A    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}/${01} Out    ${tree_node_room}/${ENCLOSURE_NAME}/${TRAY_NAME}/${01} In    ${tree_node_rack}/${PANEL_1}/${01} A
    ${information_device_3_3}    Create List    ${01} B->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${02} Out->${TRAY_NAME}->${ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${02} In->${TRAY_NAME}->${ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${01} B->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ${information_device_3_4}    Create List    ${01} A->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${01} Out->${TRAY_NAME}->${ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${01} In->${TRAY_NAME}->${ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    ${01} A->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${01}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3_3}[${i}]    objectPath=${object_path_3_3}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_3_1}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3_3}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3_4}[${i}]    objectPath=${object_path_3_4}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_3_2}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3_4}[${i}]              
    
    Select View Type On Trace    ${Scheduled}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2_1}[${i}]
    Close Trace Window
    
    ${pair_tab}    Create List    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    Open Trace Window    ${tree_node_rack}/${PANEL_3}    ${01}
    Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    1    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOUncabledInUseScheduled}    connectionType=${None}    informationDevice=${01}->${PANEL_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    ${Scheduled}
    Select View Trace Tab On Site Manager    ${Pair 1}->${First Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Pair 1}->${Second Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    Report Bug    ${SM_30324}

    :FOR    ${i}    IN RANGE    0    len(${pair_tab})
    \    Select View Trace Tab On Site Manager    @{pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    mpoType=${12}    objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOUncabledInUseScheduled}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}    informationDevice=${01}->${PANEL_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
    Close Trace Window
    # 8. Complete the job above
    Open Work Order Queue Window    
    Complete Work Order    ${building_name}
    Close Work Order Queue
    # 9. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    ${port_icon_2}    Create List    ${PortNEFDServiceInUse}    ${PortFDPanelCabledInUse}    ${PortFDPanelCabledInUse}    ${PortMPOUncabledInUse}    
    ${service_2}    Create List    ${Data}    ${Data}    ${Data}    ${Data}    
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${01}    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_2}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_2}[${i}]
    
    ${port_icon_4_1}    Create List    ${None}    ${PortFDServiceCabledBInUse}    ${PortFDPanelCabledAInUse}    ${SpliceFCabled}    ${SpliceFCabled}    ${PortFDPanelCabledAInUse}    ${PortMPOUncabledInUse}
    ${port_icon_4_2}    Create List    ${None}    ${PortFDServiceCabledAInUse}    ${PortFDPanelCabledBInUse}    ${SpliceFCabled}    ${SpliceFCabled}    ${PortFDPanelCabledBInUse}    ${PortMPOUncabledInUse}
    ${schedule_icon_4}    Create List    ${None}    ${None}    ${None}    ${None}    ${None}    ${None}    ${None}
    
    Open Trace Window    ${tree_node_rack}/${SWITCH_1}    ${01}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_2}[${i}]
    Close Trace Window
     
    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_1}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${01}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_1}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_3}    ${01}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab})
    \    Select View Trace Tab On Site Manager    @{pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    mpoType=${12}    objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOUncabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}    informationDevice=${01}->${PANEL_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
    Close Trace Window
    # 10. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the tasks from: 
    # _Switch 01// 01 to Panel 01// 01
    # _Panel 03// 01 (MPO12-6xLC-EB)/ Pair 1 to Panel 02// 01
    Open Patching Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Create Patching    ${tree_node_rack}/${SWITCH_1}    ${tree_node_rack}/${PANEL_1}   ${01}    ${01}    typeConnect=Disconnect    clickNext=${False}        
    Create Patching    ${tree_node_rack}/${PANEL_3}    ${tree_node_rack}/${PANEL_2}   ${01}    ${01}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1}
    Create Work Order    ${building_name}
    # 11. Observe the port statuses, the propagated services and trace horizontal and vertical them    
    ${port_icon_3}    Create List    ${PortNEFDServiceAvailableScheduled}    ${PortFDPanelCabledAvailableScheduled}    ${PortFDPanelCabledAvailableScheduled}    ${PortMPOUncabledAvailableScheduled}    
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${01}    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_3}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_2}[${i}]    
    
    ${port_icon_4_1}    Create List    ${None}    ${PortFDServiceCabledBAvailableScheduled}    ${PortFDPanelCabledAAvailableScheduled}    ${SpliceFCabled}    ${SpliceFCabled}    ${PortFDPanelCabledAAvailableScheduled}    ${PortMPOUncabledAvailableScheduled}
    ${port_icon_4_2}    Create List    ${None}    ${PortFDServiceCabledAAvailableScheduled}    ${PortFDPanelCabledBAvailableScheduled}    ${SpliceFCabled}    ${SpliceFCabled}    ${PortFDPanelCabledBAvailableScheduled}    ${PortMPOUncabledAvailableScheduled}

    Open Trace Window    ${tree_node_rack}/${SWITCH_1}    ${01}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    Select View Type On Trace    ${Scheduled}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_1_1}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_4_1}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_1_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_1_2}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_4_2}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_1_2}[${i}]
    Close Trace Window
    
    ${port_icon_4_3}    Create List    ${PortFDPanelCabledBAvailableScheduled}    ${SpliceFCabled}    ${SpliceFCabled}    ${PortFDPanelCabledBAvailableScheduled}
    ${port_icon_4_4}    Create List    ${PortFDPanelCabledAAvailableScheduled}    ${SpliceFCabled}    ${SpliceFCabled}    ${PortFDPanelCabledAAvailableScheduled}

    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_1}[${i}]              
    
    Select View Type On Trace    ${Scheduled}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3_1}[${i}]    objectPath=${object_path_3_1}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_4_3}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3_2}[${i}]    objectPath=${object_path_3_2}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_4_4}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3_2}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${01}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_1}[${i}]              
    
    Select View Type On Trace    ${Scheduled}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3_3}[${i}]    objectPath=${object_path_3_3}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_4_3}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3_3}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3_4}[${i}]    objectPath=${object_path_3_4}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_4_4}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3_4}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_3}    ${01}
    Select View Trace Tab On Site Manager    ${Pair 1}->${First Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_1}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Pair 1}->${Second Path}
    Check Total Trace On Site Manager    7
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_4_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_4}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab})
    \    Select View Trace Tab On Site Manager    @{pair_tab}[${i}]
    \    Check Total Trace On Site Manager    1
    \    Check Trace Object On Site Manager    1    mpoType=${12}    objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOUncabledAvailableScheduled}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}    informationDevice=${01}->${PANEL_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    1    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOUncabledAvailableScheduled}    connectionType=${None}    informationDevice=${01}->${PANEL_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
    Close Trace Window
    # 12. Complete the job above
    Open Work Order Queue Window    
    Complete Work Order    ${building_name}
    Close Work Order Queue
    # 13. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them    
    ${port_icon_4}    Create List    ${PortNEFDServiceAvailable}    ${PortFDPanelCabledAvailable}    ${PortFDPanelCabledAvailable}    ${PortMPOUncabledAvailable}    
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${01}    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_4}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_1}[${i}]    
    
    ${port_icon_5_1}    Create List    ${None}    ${PortNEFDServiceAvailable}
    ${object_path_5}    Create List    ${Config}: /${VLAN}: /${Service}: ${Data}    ${tree_node_rack}/${SWITCH_1}/${01}
    ${information_device_5}    Create List    ${Service}:->${Data}->${VLAN}:->${Config}:    ${01}->${SWITCH_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

    Open Trace Window    ${tree_node_rack}/${SWITCH_1}    ${01}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_5}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_5_1}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_5}[${i}]
    Close Trace Window
    
    ${port_icon_5_2}    Create List    ${PortFDPanelCabledBAvailable}    ${SpliceFCabled}    ${SpliceFCabled}    ${PortFDPanelCabledBAvailable}
    ${port_icon_5_3}    Create List    ${PortFDPanelCabledAAvailable}    ${SpliceFCabled}    ${SpliceFCabled}    ${PortFDPanelCabledAAvailable}

    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3_1}[${i}]    objectPath=${object_path_3_1}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_5_2}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3_2}[${i}]    objectPath=${object_path_3_2}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_5_3}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3_2}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${01}
    Select View Trace Tab On Site Manager    ${First Path}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3_3}[${i}]    objectPath=${object_path_3_3}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_5_2}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3_3}[${i}]
    
    Select View Trace Tab On Site Manager    ${Second Path}
    Check Total Trace On Site Manager    4
    :FOR    ${i}    IN RANGE    0    len(${object_index_3}) 
    \    Check Trace Object On Site Manager    ${object_index_3}[${i}]    objectPosition=${object_position_3_4}[${i}]    objectPath=${object_path_3_4}[${i}]    objectType=${object_type_3}[${i}]    
        ...    portIcon=${port_icon_5_3}[${i}]    connectionType=${connection_type_3}[${i}]    informationDevice=${information_device_3_4}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_3}    ${01}     
    Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    1    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_3}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
    ...    portIcon=${PortMPOUncabledAvailable}    connectionType=${None}    informationDevice=${01}->${PANEL_3}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
    Close Trace Window
    
SM-29808_SM-29832_SM-29833_15_Verify that the service is propagated and trace correctly in circuit: MPO12 Panel -> patched 6xLC-EB to -> LC Panel
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_15
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}        

    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}
    
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
	Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    # 3. Add to Rack 001: 
    # _MPO Panel 01
    # _LC Panel 02
    # 4. Set Data service for Panel 01// 01 directly
    Add Generic Panel    ${tree_node_rack}    ${PANEL_1}    portType=${MPO}    service=${Data}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_2}    portType=${LC}
    # 5. Create the Add Patch job and DO NOT complete the job with the task from Panel 01// 01 (MPO126xLC-EB)/Pair 1 -> Pair 2 to Panel 02// 01-02
    Open Patching Window    ${tree_node_rack}/${PANEL_1}    ${01}       
    Create Patching    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${PANEL_2}   ${01}    ${01},${02}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2}
    Create Work Order    ${building_name}
    # 6. Observe the port statuses, the propagated services and trace horizontal and vertical them
    ${tree_check_1}    Create List    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${PANEL_2}    ${tree_node_rack}/${PANEL_2}    
    ${object_1}    Create List    ${01}    ${01}    ${02}
    ${port_icon_1}    Create List    ${PortMPOServiceCabledInUseScheduled}    ${PortFDUncabledInUseScheduled}    ${PortFDUncabledInUseScheduled}
    ${service_name_1}    Create List    ${Service}    ${Service}    ${Service}    
    ${service_1}    Create List    ${Data}    ${EMPTY}    ${EMPTY}   
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${object_1}[${i}]    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_1}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_1}[${i}]    
    
    ${object_index_1}    Create List    1    2
    ${object_position_1}    Create List    ${EMPTY}    1
    ${object_path_1}    Create List    ${Config}: /${VLAN}: /${Service}: ${Data}    ${tree_node_rack}/${PANEL_1}/${01}
    ${object_type_1}    Create List    ${Service}    ${TRACE_GENERIC_MPO_PANEL_IMAGE}
    ${port_icon_1}    Create List    ${None}    ${PortMPOServiceCabledInUseScheduled}
    ${connection_type_1}    Create List    ${TRACE_ASSIGN}    ${None}
    ${information_device_1}    Create List    ${Service}:->${Data}->${VLAN}:->${Config}:    ${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_1}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_1}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_1}[${i}]
    
    ${object_index_2}    Create List    1    2    3
    ${object_position_2_1}    Create List    ${EMPTY}    1 [${A1}]    1 [${Pair 1}]    
    ${object_position_2_2}    Create List    ${EMPTY}    1 [${A1}]    2 [${Pair 2}]
    ${object_path_2_1}    Create List    ${Config}: /${VLAN}: /${Service}: ${Data}    ${tree_node_rack}/${PANEL_1}/${01}    ${tree_node_rack}/${PANEL_2}/${01}
    ${object_path_2_2}    Create List    ${Config}: /${VLAN}: /${Service}: ${Data}    ${tree_node_rack}/${PANEL_1}/${01}    ${tree_node_rack}/${PANEL_2}/${02}
    ${object_type_2}    Create List    ${Service}    ${TRACE_GENERIC_MPO_PANEL_IMAGE}    ${TRACE_GENERIC_LC_PANEL_IMAGE}
    ${port_icon_2}    Create List    ${None}    ${PortMPOServiceCabledInUseScheduled}    ${PortFDUncabledInUseScheduled}
    ${connection_type_2}    Create List    ${TRACE_ASSIGN}    ${TRACE_MPO12_6X_LC_EB_PATCHING}    ${None}
    ${schedule_icon_2}    Create List    ${None}    ${TRACE_SCHEDULED_WORK_TIME_PERIOD}    ${None}    
    ${information_device_2_1}    Create List    ${Service}:->${Data}->${VLAN}:->${Config}:    ${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${01}->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ${information_device_2_2}    Create List    ${Service}:->${Data}->${VLAN}:->${Config}:    ${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ...    ${02}->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

    ${pair_tab}    Create List    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    Select View Type On Trace    ${Scheduled}
    Select View Trace Tab On Site Manager    ${Pair 1}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Pair 2}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    Report Bug    ${SM_30324}

    :FOR    ${i}    IN RANGE    0    len(${pair_tab})
    \    Select View Trace Tab On Site Manager    @{pair_tab}[${i}]
    \    Check Total Trace On Site Manager    2
    \    Check Trace Object On Site Manager    1    objectPosition=${EMPTY}    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=Service    
        ...    portIcon=${None}    connectionType=${TRACE_ASSIGN}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
    \    Check Trace Object On Site Manager    2    mpoType=${12}    objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledInUseScheduled}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${01}
    Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    1    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_2}/${01}    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    
    ...    portIcon=${PortFDUncabledInUseScheduled}    connectionType=${None}    informationDevice=${01}->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2_1}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${02}
    Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    1    objectPosition=2    objectPath=${tree_node_rack}/${PANEL_2}/${02}    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    
    ...    portIcon=${PortFDUncabledInUseScheduled}    connectionType=${None}    informationDevice=${02}->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_2}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_2}[${i}]    informationDevice=${information_device_2_2}[${i}]
    Close Trace Window
    # 7. Complete the job above
    Open Work Order Queue Window    
    Complete Work Order    ${building_name}
    Close Work Order Queue
    # 8. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    ${port_icon_2}    Create List    ${PortMPOServiceCabledInUse}    ${PortFDUncabledInUse}    ${PortFDUncabledInUse}
    ${service_2}    Create List    ${Data}    ${Data}    ${Data}   
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${object_1}[${i}]    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_2}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_2}[${i}]
    
    ${port_icon_3}    Create List    ${None}    ${PortMPOServiceCabledInUse}    ${PortFDUncabledInUse}
    ${schedule_icon_3}    Create List    ${None}    ${None}    ${None}

    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Type On Trace    ${Scheduled}
    Select View Trace Tab On Site Manager    ${Pair 1}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_3}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_3}[${i}]    informationDevice=${information_device_2_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Pair 2}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_3}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_3}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab})
    \    Select View Trace Tab On Site Manager    @{pair_tab}[${i}]
    \    Check Total Trace On Site Manager    2
    \    Check Trace Object On Site Manager    1    objectPosition=${EMPTY}    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=Service    
        ...    portIcon=${None}    connectionType=${TRACE_ASSIGN}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
    \    Check Trace Object On Site Manager    2    mpoType=${12}    objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${01}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_3}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_3}[${i}]    informationDevice=${information_device_2_1}[${i}]
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${02}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_3}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_3}[${i}]    informationDevice=${information_device_2_2}[${i}]
    Close Trace Window
    # 9. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the task from Panel 01// 01 (MPO12-6xLC-EB)/ Pair 1 -> Pair 2 to Panel 02// 01-02
    Open Patching Window    ${tree_node_rack}/${PANEL_1}    ${01}       
    Create Patching    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${PANEL_2}   ${01}    ${01},${02}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2}
    Create Work Order    ${building_name}
    # 10. Observe the port statuses, the propagated services and trace horizontal and vertical them
    ${port_icon_4}    Create List    ${PortMPOServiceCabledAvailableScheduled}    ${PortFDUncabledAvailableScheduled}    ${PortFDUncabledAvailableScheduled}
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${object_1}[${i}]    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_4}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_2}[${i}]    
    
    ${port_icon_5}    Create List    ${None}    ${PortMPOServiceCabledAvailableScheduled}    ${PortFDUncabledAvailableScheduled}

    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Select View Trace Tab On Site Manager    ${Pair 1}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_5}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_3}[${i}]    informationDevice=${information_device_2_1}[${i}]
    
    Select View Trace Tab On Site Manager    ${Pair 2}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_5}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_3}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    :FOR    ${i}    IN RANGE    0    len(${pair_tab})
    \    Select View Trace Tab On Site Manager    @{pair_tab}[${i}]
    \    Check Total Trace On Site Manager    2
    \    Check Trace Object On Site Manager    1    objectPosition=${EMPTY}    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=Service    
        ...    portIcon=${None}    connectionType=${TRACE_ASSIGN}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
    \    Check Trace Object On Site Manager    2    mpoType=${12}    objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
        ...    portIcon=${PortMPOServiceCabledAvailableScheduled}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    ${port_icon_6}    Create List    ${None}    ${PortMPOServiceCabledAvailableScheduled}

    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_1}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_6}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_1}[${i}]    
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${01}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_1}[${i}]    objectPath=${object_path_2_1}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_5}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_3}[${i}]    informationDevice=${information_device_2_1}[${i}]
    
    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    1    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_2}/${01}    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    
    ...    portIcon=${PortFDUncabledAvailableScheduled}    connectionType=${None}    informationDevice=${01}->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${02}
    Check Total Trace On Site Manager    3
    :FOR    ${i}    IN RANGE    0    len(${object_index_2}) 
    \    Check Trace Object On Site Manager    ${object_index_2}[${i}]    objectPosition=${object_position_2_2}[${i}]    objectPath=${object_path_2_2}[${i}]    objectType=${object_type_2}[${i}]    
        ...    portIcon=${port_icon_5}[${i}]    connectionType=${connection_type_2}[${i}]    scheduleIcon=${schedule_icon_3}[${i}]    informationDevice=${information_device_2_2}[${i}]
    
    Select View Type On Trace    ${Scheduled}
    Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    1    objectPosition=2    objectPath=${tree_node_rack}/${PANEL_2}/${02}    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    
    ...    portIcon=${PortFDUncabledAvailableScheduled}    connectionType=${None}    informationDevice=${02}->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    # 11. Complete the job above
    Open Work Order Queue Window    
    Complete Work Order    ${building_name}
    Close Work Order Queue
    # 12. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    ${port_icon_7}    Create List    ${PortMPOServiceCabledAvailable}    ${PortFDUncabledAvailable}    ${PortFDUncabledAvailable}
    :FOR    ${i}    IN RANGE    0    len(${tree_check_1})
    \    Click Tree Node On Site Manager    ${tree_check_1}[${i}]
    \    Select Object On Content Table    ${object_1}[${i}]    
    \    Check Icon Object Exist On Content Pane    ${01}    ${port_icon_7}[${i}]    
    \    Check Object Properties On Properties Pane    ${service_name_1}[${i}]    ${service_1}[${i}]    
    
    ${port_icon_8}    Create List    ${None}    ${PortMPOServiceCabledAvailable}

    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Check Total Trace On Site Manager    2
    :FOR    ${i}    IN RANGE    0    len(${object_index_1}) 
    \    Check Trace Object On Site Manager    ${object_index_1}[${i}]    objectPosition=${object_position_1}[${i}]    objectPath=${object_path_1}[${i}]    objectType=${object_type_1}[${i}]    
        ...    portIcon=${port_icon_8}[${i}]    connectionType=${connection_type_1}[${i}]    informationDevice=${information_device_1}[${i}]    
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${01}
    Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    1    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_2}/${01}    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    
    ...    portIcon=${PortFDUncabledAvailable}    connectionType=${None}    informationDevice=${01}->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_2}    ${02}
    Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    1    objectPosition=2    objectPath=${tree_node_rack}/${PANEL_2}/${02}    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    
    ...    portIcon=${PortFDUncabledAvailable}    connectionType=${None}    informationDevice=${02}->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window

    