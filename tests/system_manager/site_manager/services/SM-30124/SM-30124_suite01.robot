*** Settings ***
Resource    ../../../../../resources/constants.robot
Resource    ../../../../../resources/icons_constants.robot

Library    ../../../../../py_sources/logigear/setup.py
Library    ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}        
Library    ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/services/change_service/ChangeServicePage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/services/decommission_server/DecommissionServerPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/work_order_queue/WorkOrderQueuePage${PLATFORM}.py   
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/front_to_back_cabling/FrontToBackCablingPage${PLATFORM}.py    


Suite Setup    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}

Suite Teardown    Close Browser

Default Tags    Services
Force Tags    SM-30124

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
SM-30124-07_Verify that Change Service is not found circuit contains new 6x
    [Setup]    Run Keywords    Set Test Variable    ${BUILDING_NAME}    SM-30124-07
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}
    ...    AND    Reload Page    

    [Teardown]    Run Keywords    Reload Page
    ...    AND    Delete Building     ${building_name}        

    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}        
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    ${tree_node_rack} =     Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}    position=1
    # 3. Add to Rack 001:
    # _MPO12 Switch 01
    # _LC Panel 01
    # _LC Panel 02
    Add Network Equipment    ${tree_node_rack}    ${SWITCH_1}
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_1}    ${01}    ${MPO12}    quantity=2
    Add Generic Panel    ${tree_node_rack}    ${PANEL_1}    portType=${LC}    quantity=2
    # 4. Set:
    # _Voice service in Switch 01/01
    # _Data service in Switch 01/02
    Edit Port On Content Table    ${tree_node_rack}/${SWITCH_1}    ${01}    listChannel=${01}    listServiceType=${Voice}
    # Wait For Port Icon Change On Content Table    ${01}    
    Edit Port On Content Table    ${tree_node_rack}/${SWITCH_1}    ${02}    listChannel=${02}    listServiceType=${Data}
    # Wait For Port Icon Change On Content Table    ${02}            
    # 5. Open Cabling window, cable from:
    # _Switch 01/01 (MPO12-6xLC EB) to Panel 01/01->06
    Open Cabling Window    ${tree_node_rack}/${SWITCH_1}    ${01}
    Create Cabling    Connect    ${tree_node_rack}/${SWITCH_1}/${01}    ${tree_node_rack}/${PANEL_1}    ${MPO12}    ${Mpo12_6xLC_EB}    ${Pair 1}    ${01}
    Close Cabling Window
    Wait For Port Icon Change On Content Table    ${01}
    # 6. Open Patching window, patch from:
    # _LC Panel 01/01->06 to LC Panel 02/01->06
    # Complete this job
    Open Patching Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Create Patching    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${PANEL_2}    ${01}    ${01}    clickNext=${False}    
    Create Patching    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${PANEL_2}    ${02}    ${02}    clickNext=${False}    
    Create Patching    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${PANEL_2}    ${03}    ${03}    clickNext=${False}    
    Create Patching    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${PANEL_2}    ${04}    ${04}    clickNext=${False}    
    Create Patching    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${PANEL_2}    ${05}    ${05}    clickNext=${False}   
    Create Patching    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${PANEL_2}    ${06}    ${06}    createWo=${False}     
    Wait For Port Icon Change On Content Table    ${01}
    # 7. Select LC Panel 02/01->06 and open Change Service window
    # 8. Change from Voice to Data service
    # 9. Click on Shown link and observe
    Open Services Window    Change Service    ${tree_node_rack}/${PANEL_2}    ${01}
    Change Service    ${tree_node_rack}/${PANEL_2}/${01}    ${Data}
    Check Service Conclusion    Service Found.
    Check Trace Object On Create Work Order    1    objectPosition=${EMPTY}    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Service}
    ...    connectionType=${TRACE_ASSIGN}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
    Check Trace Object On Create Work Order    2    objectPosition=2 [A1]    objectPath=${tree_node_rack}/${SWITCH_1}/${02}    objectType=${TRACE_SWITCH_IMAGE}
    ...    connectionType=${TRACE_MPO12_4LC_PATCHING}    scheduleIcon=${TRACE_SCHEDULED_WORK_TIME_PERIOD}    informationDevice=${02}->${SWITCH_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Check Trace Object On Create Work Order    3    objectPosition=1 [${1-1}]    objectPath=${tree_node_rack}/${PANEL_2}/${01}    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}
    ...    informationDevice=${01}->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    closeDialog=${True}


SM-30124-08-Verify that the user can decommission server with 6xLC EB:Switch -> patched 6xLC EB to -> MPO12 Panel -> cabled to -> MPO12 Panel -> patched 6xLC EB to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${BUILDING_NAME}    SM-30124-08
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}
    ...    AND    Reload Page
    
    [Teardown]    Run Keywords    Reload Page
    ...    AND    Delete Building     ${building_name}

    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_POSITION}
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}        
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    ${tree_node_rack} =     Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}    position=1

    # 3. Add to Rack 001:
    # _LC Switch 01
    # _MPO Generic Panel 01
    # _MPO Generic Panel 02
    # _LC Server 01
    Add Network Equipment    ${tree_node_rack}    ${SWITCH_1}
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_1}    ${01}    ${LC}    quantity=6
    Add Generic Panel    ${tree_node_rack}    ${PANEL_1}    portType=${MPO}    quantity=2
    Add Device In Rack    ${tree_node_rack}    ${SERVER_1}
    Add Device In Rack Port    ${tree_node_rack}/${SERVER_1}    ${01}    ${LC}    quantity=6
    # 4. Patch 6xLC EB from Panel 01/01 to Switch 01/01-06
    Open Patching Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Create Patching    ${tree_node_rack}/${PANEL_1}    ${tree_node_rack}/${SWITCH_1}    ${01}    ${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}
    ...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    createWo=${False}
    Wait For Port Icon Change On Content Table    ${01}    
    # 5. Cable from Panel 01/01 to Panel 02/01
    Open Cabling Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Create Cabling    Connect    ${tree_node_rack}/${PANEL_1}/${01}    ${tree_node_rack}/${PANEL_2}    portsTo=${01}    
    Close Cabling Window
    Wait For Port Icon Change On Content Table    ${01}    
    # 6. Patch 6xLC EB from Panel 02/01 to Server 01/01-06
    Open Patching Window    ${tree_node_rack}/${PANEL_2}    ${01}
    Create Patching    ${tree_node_rack}/${PANEL_2}    ${tree_node_rack}/${SERVER_1}    ${01}    ${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}
    ...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    createWo=${False}
    Wait For Port Icon Change On Content Table    ${01}     
    # 7. Select Server 01 and decommission server    
    Open Services Window    Decommission Server    ${tree_node_rack}/${SERVER_1}
    # 8. In Remove Patch Connection window, set on options:
    # _Remove all patch connections
    # _Delete server from the database after the work order is completed
    # 9. Continue to go to Decommission for Server 01
    Decommission Server    1
    # 10. Create Decommission Server job
    Create Work Order    ${building_name}
    Wait For Work Order Icon On Content Table    ${SERVER_1} 
    # 11. Check ports status
    @{object_content}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_1}
    :FOR    ${object}    IN    @{object_content}
    \    Select Object On Content Table    ${object}
    \    Check Object Properties On Properties Pane    Port Status    ${Available - Pending}   
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_1}     
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    Port Status    ${Available - Pending}   
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_2}     
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    Port Status    ${Available - Pending}
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_1}
    :FOR    ${object}    IN    @{object_content}
    \    Select Object On Content Table    ${object}
    \    Check Object Properties On Properties Pane    Port Status    ${Available - Pending}    
    # 12. Complete job above and observe port status
    Open Work Order Queue Window    
    Complete Work Order    ${building_name}
    Close Work Order Queue
    Wait For Work Order Icon On Content Table    ${SERVER_1}    exist=${False}
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_1}
    :FOR    ${object}    IN    @{object_content}
    \    Select Object On Content Table    ${object}
    \    Check Object Properties On Properties Pane    Port Status    ${Available}   
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_1}     
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    Port Status    ${Available}   
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_2}     
    Select Object On Content Table    ${01}
    Check Object Properties On Properties Pane    Port Status    ${Available}
    
    Check Tree Node Not Exist On Site Manager    ${tree_node_rack}/${SERVER_1}       
    # 13. Trace Panel 01/01 and observe the circuit
    Open Trace Window    ${tree_node_rack}/${PANEL_1}    ${01}
    Check Total Trace On Site Manager    2
    Check Trace Object On Site Manager    1    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
    Check Trace Object On Site Manager    2    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
    Close Trace Window                
   
SM-30124-09-Verify that the user can decommission server with 6xLC EB: LC Switch -> cabled 6xLC to -> MPO12 Panel -> F2B cabling to -> MPO12 Panel -> patched 6xLC to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${BUILDING_NAME}    SM-30124-09
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}
    ...    AND    Reload Page

    [Teardown]    Run Keywords    Reload Page
    ...    AND    Delete Building     ${BUILDING_NAME}        

    # 1. Login to SM
    # 2. Add Building 01/Floor 01/Room 01/Rack 001 to Site
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}        
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    ${tree_node_rack} =     Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}    position=1

    # 3. Add to Rack 001:
    # _LC Switch 01
    # _MPO Generic Panel 01
    # _MPO Generic Panel 02
    # _LC Server 01
    ${LC_Switch_Treenode} =    Add Network Equipment    ${tree_node_rack}    ${SWITCH_1}       
    Add Network Equipment Port    ${LC_Switch_Treenode}    ${01}    ${LC}    quantity=${12}
    ${MPO_Panel_1_Treenode}=    Add Generic Panel    ${tree_node_rack}    ${PANEL_1}    portType=${MPO}
    ${MPO_Panel_2_Treenode}=    Add Generic Panel    ${tree_node_rack}    ${PANEL_2}    portType=${MPO}
    Add Device In Rack    ${tree_node_rack}    ${SERVER_1}
    Add Device In Rack Port    ${tree_node_rack}/${SERVER_1}    ${01}    ${LC}    quantity=${12}
    
    # 4. Cable 6xLC EB from Panel 01/01 to Switch 01/01-06
    Open Cabling Window    ${MPO_Panel_1_Treenode}
    Create Cabling    cableFrom=${MPO_Panel_1_Treenode}/${01}    cableTo=${LC_Switch_Treenode}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}
    ...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    portsTo=${01},${02},${03},${04},${05},${06}
    Close Cabling Window

    # 5. F2B MPO12-MPO12 from Panel 01/01 to Panel 02/01
    Open Front To Back Cabling Window    ${MPO_Panel_1_Treenode}
    Create Front To Back Cabling    ${MPO_Panel_1_Treenode}    ${MPO_Panel_2_Treenode}    portsFrom=${01}    portsTo=${01}    mpoTab=${MPO12}    mpoType=${Mpo12_Mpo12}
    Close Front To Back Cabling Window

    # 6. Patch 6xLC EB from Panel 02/01 to Server 01/01-06
    Open Patching Window    ${MPO_Panel_2_Treenode}
    Create Patching    ${MPO_Panel_2_Treenode}    ${tree_node_rack}/${SERVER_1}    ${01}    ${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}
    ...    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    createWo=${False}
    
    # 7. Select Server 01 and decommission server
    Open Services Window    Decommission Server    ${tree_node_rack}/${SERVER_1}
    
    # 8. In Remove Patch Connection window:
    # _Set on option:
    # Remove all patch connections except for direct connection to the switch
    # _Set off option:
    # Delete server from the database after the work order is completed
    Decommission Server    ${2}    ${False}
    Create Work Order    ${BUILDING_NAME}
    Wait For Work Order Icon On Content Table    ${SERVER_1}    

    # 9. Continue to go to Decommission for Server 01
    # 10. Create Decommission Server job 
    # 11. Check ports status
    # * Step 11:
    # _Switch 01/01-06: In Use
    # _Panel 01/01: In Use
    # _Panel 02/01: Available - Pending
    # _Server 01/01-06: Available - Pending
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${Status_InUSe}    Create List    ${In Use}    ${In Use}    ${In Use}    ${In Use}    ${In Use}    ${In Use}
    ${Status_AvlPen}    Create List    ${Available - Pending}    ${Available - Pending}    ${Available - Pending}    ${Available - Pending}    ${Available - Pending}    ${Available - Pending}
    ${Status_Available}    Create List    ${Available}    ${Available}    ${Available}    ${Available}    ${Available}    ${Available}
    ${Line_position}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
    ${pair_list}    Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    Click Tree Node On Site Manager    ${LC_Switch_Treenode}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortNEFDPanelCabled}
    :FOR    ${i}    IN RANGE    0    len(${port_list})  
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Status_InUSe}[${i}]    ${Line_position}[${i}]

    Click Tree Node On Site Manager    ${MPO_Panel_1_Treenode}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOServiceCabledInUse}
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    ${1}
    
    Click Tree Node On Site Manager    ${MPO_Panel_2_Treenode}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOPanelCabledAvailableScheduled}
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    ${1}
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_1}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledAvailableScheduled}
    :FOR    ${i}    IN RANGE    0    len(${port_list})  
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Status_AvlPen}[${i}]    ${Line_position}[${i}]
    
    # 12. Complete job above and observe port status
    # _Switch 01/01-06: In Use
    # _Panel 01/01: In Use
    # _Panel 02/01: Available
    # _Server 01/01-06: Available
    Open Work Order Queue Window
    Complete Work Order    ${BUILDING_NAME}  
    Close Work Order Queue
    
    Click Tree Node On Site Manager    ${LC_Switch_Treenode}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortNEFDPanelCabled}
    :FOR    ${i}    IN RANGE    0    len(${port_list})  
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Status_InUSe}[${i}]    ${Line_position}[${i}]
    
    Click Tree Node On Site Manager    ${MPO_Panel_1_Treenode}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOServiceCabledInUse}
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    ${1}
    
    Click Tree Node On Site Manager    ${MPO_Panel_2_Treenode}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOPanelCabledAvailable}
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_1}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledAvailable}
    :FOR    ${i}    IN RANGE    0    len(${port_list})  
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Status_Available}[${i}]    ${Line_position}[${i}]  

    # 13. Trace Panel 01/01 and observe the circuit
    # _Pair 1: Service box -> connected to -> Switch 01/1 [Pair 1] -> cabled 6xLC EB -> Panel 01/01 -> f2b cabled to -> Panel 02/01
    # ...
    # _Pair 6: Service box -> connected to -> Switch 01/6 [Pair 6] -> cabled 6xLC EB -> Panel 01/01 -> f2b cabled to -> Panel 02/01
    Open Trace Window    ${MPO_Panel_1_Treenode}    ${01}
	:FOR    ${i}    IN RANGE    0    len(${pair_list})    
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
	\    Check Total Trace On Site Manager    ${4}
	\    Check Trace Object On Site Manager    indexObject=${1}    objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}
	    ...    objectType=${TRACE_SERVICE}    connectionType=${TRACE_ASSIGN}    
	    ...    informationDevice=${TRACE_OBJECT_SERVICE}->${EMPTY}->${TRACE_VLAN}->${TRACE_CONFIG}      
	\    Check Trace Object On Site Manager    indexObject=${2}    objectPosition=${Line_position}[${i}] [${pair_list}[${i}]]    
	    ...    objectPath=${LC_Switch_Treenode}/${port_list}[${i}]    objectType=${TRACE_SWITCH_IMAGE}    
	    ...    portIcon=${PortNEFDPanelCabled}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    
	    ...    informationDevice=${port_list}[${i}]->${SWITCH_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${BUILDING_NAME}->${SITE_NODE}         
	\    Check Trace Object On Site Manager    indexObject=${3}    mpoType=${12}    objectPosition=${1} [ /${A1}]    
	    ...    objectPath=${MPO_Panel_1_Treenode}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	    ...    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
	    ...    informationDevice=${01}->${PANEL_1}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${BUILDING_NAME}->${SITE_NODE} 
	\    Check Trace Object On Site Manager    indexObject=${4}    mpoType=${12}    objectPosition=${1}    
	    ...    objectPath=${MPO_Panel_2_Treenode}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    
	    ...    portIcon=${PortMPOPanelCabledAvailable}    informationDevice=${01}->${PANEL_2}->${RACK_POSITION}->${ROOM_NAME}->${FLOOR_NAME}->${BUILDING_NAME}->${SITE_NODE}
    Close Trace Window               
