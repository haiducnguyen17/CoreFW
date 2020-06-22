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
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/front_to_back_cabling/FrontToBackCablingPageDesktop.py    

Default Tags    Connectivity
Force Tags    SM-29808_SM-29832_SM-29833

*** Variables ***
${FLOOR_NAME_1}    Floor 01
${ROOM_NAME}    Room 01
${RACK_NAME}    Rack 001
${SWITCH_NAME_1}    Switch 01
${SWITCH_NAME_2}    Switch 02
${SERVER_NAME_1}    Server 01
${CARD_NAME_1}    Card 01
${PANEL_NAME_1}    Panel 01
${PANEL_NAME_2}    Panel 02
${PANEL_NAME_3}    Panel 03
${PANEL_NAME_4}    Panel 04
${GBIC_SLOT_1}    GBIC Slot 01
${ZONE}    1
${POSITION}    1
${POSITION_RACK_NAME}    1:1 Rack 001
${MEDIA_CONVERTER_NAME}    MC 01

*** Test Cases ***
SM-29808_SM-29832_01-Verify that the service is propagated and trace correctly in new customer circuit (IBM): LC Switch -> patched to -> DM12 -> cabled to -> MPO12 Panel -> patched 6xLC to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM-29808_SM-29832_01
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}
       
    [Tags]    SM-29808_SM-29832_SM-29833
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tc_wo_name}    Set Variable    WO_SM-29808-29832_01
    ${port_list_1}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${trace_building_name}    Set Variable    ..29808_SM-29832_01
    ${trace_tab_list_1}    Create List    1-12    2-11    3-10    4-9    5-8    6-7
    ${pair_list_1}    Create List     ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${position_list}    Set Variable     1    2    3    4    5    6
        
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001: 
	# _LC Switch 01
	# _InstaPatch Panel 01 (DM12)
	# _MPO Panel 02
	# _LC Server 01
	# 4. Set Data service for Switch 01// 01-06 directly
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME_1}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_1}    
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_NAME_1}    name=${01}    portType=${LC}
    ...    listChannel=${01}    listServiceType=${Data}    quantity=6
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_1}    ${Module 1A},True,${LC 12 Port},${DM12}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_2}    portType=${MPO}
    Add Device In Rack    ${tree_node_rack}    ${SERVER_NAME_1}
    Add Device In Rack Port    ${tree_node_rack}/${SERVER_NAME_1}    ${01}    portType=${LC}    quantity=6
  
	# 5. Cable from Panel 01// MPO 01 (MPO12-MPO12) to Panel 02// 01
	Open Cabling Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${01}
    Create Cabling    cableFrom=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${MPO} ${01}    cableTo=${tree_node_rack}/${PANEL_NAME_2}
    ...    portsTo=${01}
    Close Cabling Window

	# 6. Create the Add Patch job and DO NOT complete the job with the tasks from: 
	# _Switch 01// 01-06 to Panel 01// 01-06
	# _Panel 02// 01 (MPO12-MPO12)/ 1-1 -> 6-6 to Server 01// 01-06
	Open Patching Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
	:FOR    ${i}    IN RANGE    0    len(${port_list_1})
	 \    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})
	 ...    portsFrom=${port_list_1}[${i}]    portsTo=${port_list_1}[${i}]
	 ...    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_2}    patchTo=${tree_node_rack}/${SERVER_NAME_1}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    createWo=${True}    clickNext=${True}
    Create Work Order    ${tc_wo_name}

    # 7. Observe the port statuses, the propagated services and trace horizontal and vertical them
    # _Port statuses for Switch 01// 01-06, Panel 01// 01-06, Panel 02// 01 and Server 01// 01-06: In Use - Pending
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use - Pending}    ${i+1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use - Pending}    ${i+1}

    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    ${1}  
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use - Pending}    ${i+1}
   
    # _Data service is NOT propagated on the Properties pane/window of Panel 01// 01-06, Panel 02// 01 and Server 01// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY}    
	
	# _The circuit trace displays: 
	  # +Current View: 
	     # .For Switch 01// 01-06: Switch 01// 01-06/ 1-6
	     # .For Panel 01// 01-06 and Panel 02// 01: Panel 02// 01/ 1 -> cabled to -> Panel 01// 01-06/ 1-6 (MPO1)
	     # .For Server 01// 01-06: Server 01// 01-06/ 1-6
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
    ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    
    
 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=${12}    objectPosition=1   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
 	:FOR    ${i}     IN RANGE    0    len(${trace_tab_list_1})
 	\    Select View Trace Tab On Site Manager    ${trace_tab_list_1}[${i}]
 	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=${12}    objectPosition=1   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SERVER_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    1
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

	# +Scheduled View: Switch 01// 01-06/ 1-6 -> patched to -> Panel 01// 01-06/ 1-6 (MPO1) -> cabled to -> Panel 02// 01/ 1 [A1] -> patched to -> Server 01// 01-06/ 1 [1-1] - 6 [6-6]
	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
	Select View Type On Trace    Scheduled
	:FOR    ${i}     IN RANGE    0    len(${pair_list_1})
 	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]
	\    Check Total Trace On Site Manager    5
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
    ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=${12}    objectPosition=1 [${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
    # 8. Complete the job above
    Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue

    # 9. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 9: 
	# _Port icons for: 
	  # +Switch 01// 01-06: patched icon (including purple icon)
	  # +Panel 01// 01-06, Panel 02// 01: cabled and patched icons
	  # +Server 01// 01-06: patched icon
	# _Port statuses for Switch 01// 01-06, Panel 01// 01-06, Panel 02// 01 and Server 01// 01-06: In Use
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}   
    Wait For Port Icon Change On Content Table    ${01}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    
	Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDPanelCabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}

    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}
    Wait For Port Icon Change On Content Table    ${01}   
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    ${1}
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}    
	Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDUncabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}  

	## _Data service is propagated on the Properties pane/window of Panel 01// 01-06, Panel 02// 01 and Server 01// 01-06.
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${Data}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${Data}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Current Service}    ${Data} 

	# _The circuit trace displays: 
	  # +Current View: like Scheduled View in step 7.
    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
	:FOR    ${i}     IN RANGE    0    len(${pair_list_1})
 	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]
	\    Check Total Trace On Site Manager    5
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
    ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=${12}    objectPosition=1 [${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
    # 10. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the tasks from: 
	# _Switch 01// 01-06 to Panel 01// 01-06
	# _Panel 02// 01 (MPO12-MPO12)/ 1-1 -> 6-6 to Server 01// 01-06 
	Open Patching Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
	:FOR    ${i}    IN RANGE    0    len(${port_list_1})
	 \    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})
	 ...    portsFrom=${port_list_1}[${i}]    portsTo=${port_list_1}[${i}]    typeConnect=Disconnect 
	 ...    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_2}    patchTo=${tree_node_rack}/${SERVER_NAME_1}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    createWo=${True}    clickNext=${True}
    Create Work Order    ${tc_wo_name}
    
    # 11. Observe the port statuses, the propagated services and trace horizontal and vertical them
        # * Step 11: 
	# _Port statuses for Switch 01// 01-06, Panel 01// 01-06, Panel 02// 01 and Server 01// 01-06: Available - Pending
	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}

    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    ${1}  
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}
	
	# _Data service is still propagated on the Properties pane/window of Panel 01// 01-06, Panel 02// 01 and Server 01// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${Data}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${Data}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Current Service}    ${Data} 	
	
	# _The circuit trace displays: 
	  # +Current View: like Scheduled View in step 7
    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
	:FOR    ${i}     IN RANGE    0    len(${pair_list_1})
 	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]
	\    Check Total Trace On Site Manager    5
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
    ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=${12}    objectPosition=1 [${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window

	  # +Scheduled View: like Current View in step 7
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
    ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    
    
 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=${12}    objectPosition=1   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
	Select View Type On Trace    Scheduled
 	:FOR    ${i}     IN RANGE    0    len(${trace_tab_list_1})
 	\    Select View Trace Tab On Site Manager    ${trace_tab_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=${12}    objectPosition=1   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SERVER_NAME_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    1
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 	
 
    # 12. Complete the job above
    Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue 
	 
	# 13. Observe  the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# _Port icons for: 
	  # +Switch 01// 01-06: no patched icon (including purple icon)
	  # +Panel 01// 01-06, Panel 02// 01: no cabled icon but no patched icon
	  # +Server 01// 01-06: no patched icon
	# _Port statuses for Switch 01// 01-06, Panel 01// 01-06, Panel 02// 01 and Server 01// 01-06: Available
	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}   
	Wait For Port Icon Change On Content Table    ${01}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    
	Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDPanelCabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1}

    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}
    Wait For Port Icon Change On Content Table    ${01}   
	Check Icon Object Not Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}    
	Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDUncabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1}  

	# _Data service is NOT propagated on the Properties pane/window of Panel 01// 01-06, Panel 02// 01 and Server 01// 01-06.
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY} 
	
	# _The circuit trace displays: 
	  # +Current View: like Current View in step 7
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
    ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    
    
 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=${12}    objectPosition=1   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
 	:FOR    ${i}     IN RANGE    0    len(${trace_tab_list_1})
 	\    Select View Trace Tab On Site Manager    ${trace_tab_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=${12}    objectPosition=1   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SERVER_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    1
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 	

SM-29808_SM-29832_02-Verify that the service is propagated and trace correctly in new customer circuit: LC Switch -> patched to -> DM12 -> cabled 6xLC to -> LC -> F2B cabling 6xLC -> DM12 -> patched to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM-29808_SM-29832_02
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}
       
    [Tags]    SM-29808_SM-29832_SM-29833
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tc_wo_name}    Set Variable    WO_SM-29808-29832_02
    ${port_list_1}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${trace_building_name}    Set Variable    ..29808_SM-29832_02
    ${position_list}    Set Variable     1    2    3    4    5    6
        
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001: 
	# _LC Switch 01
	# _InstaPatch Panel 01 (DM12)
	# _LC non-iPatch Panel 02
	# _InstaPatch Panel 03 (DM12)
	# _LC Server 01
	# 4. Set Data service for Switch 01// 01-06 directly
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME_1}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_1}    
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_NAME_1}    name=${01}    portType=${LC}
    ...    listChannel=${01}    listServiceType=${Data}    quantity=6
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (2U)}    ${PANEL_NAME_1}    ${Module 1A},True,${LC 12 Port},${DM12}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_2}    portType=${LC}
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${HD Fiber Shelf (1U)}    ${PANEL_NAME_3}    ${Module 1A},True,${LC 12 Port},${DM12}
    Add Device In Rack    ${tree_node_rack}    ${SERVER_NAME_1}
    Add Device In Rack Port    ${tree_node_rack}/${SERVER_NAME_1}    ${01}    portType=${LC}    quantity=6
  
    # 5. Cable from Panel 01// MPO 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Panel 02// 01-06
	Open Cabling Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${01}
    Create Cabling    cableFrom=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${MPO} ${01}    cableTo=${tree_node_rack}/${PANEL_NAME_2}
    ...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    portsTo=${01},${02},${03},${04},${05},${06}
    Close Cabling Window
    
    # 6. F2B cabling from Panel 02// 01-06 (6xLC-MPO12) to Panel 03// MPO 01/ 1-1 -> 6-6
    Open Front To Back Cabling Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
    Create Front To Back Cabling    ${tree_node_rack}/${PANEL_NAME_2}    ${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})
    ...    portsFrom=${01},${02},${03},${04},${05},${06}    portsTo=${MPO} ${01}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB_Symmetry}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    Close Front To Back Cabling Window

	# 7. Create the Add Patch job and DO NOT complete the job with the tasks from: 
	# _Switch 01// 01-06 to Panel 01// 01-06
	# _Panel 03// 01-06 to Server 01// 01-06
	Open Patching Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
	:FOR    ${i}    IN RANGE    0    len(${port_list_1})
	 \    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})
	 ...    portsFrom=${port_list_1}[${i}]    portsTo=${port_list_1}[${i}]
	 ...    createWo=${True}    clickNext=${False}
	:FOR    ${i}    IN RANGE    0    len(${port_list_1})
	 \    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})    patchTo=${tree_node_rack}/${SERVER_NAME_1}
	 ...    portsFrom=${port_list_1}[${i}]    portsTo=${port_list_1}[${i}]
	 ...    createWo=${True}    clickNext=${False}
    Save Patching Window
    Create Work Order    ${tc_wo_name}

    # 8. Observe the port statuses, the propagated services and trace horizontal and vertical them
	# _Port statuses for: 
	  # +Switch 01// 01-06, Panel 01// 01-06, Panel 03// 01-06 and Server 01// 01-06: In Use - Pending
	  # +Panel 02// 01-06: In Use
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use - Pending}    ${i+1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use - Pending}    ${i+1}
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use - Pending}    ${i+1}

    Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use - Pending}    ${i+1}

    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}
 
    # _Data service is NOT propagated on the Properties pane/window of Panel 01-03// 01-06 and Server 01// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY} 	 
	
	# _The circuit trace displays: 
	  # +Current View: 
	     # .For Switch 01// 01-06: Switch 01// 01-06/ 1-6
	     # .For Panel 01-03// 01-06: Panel 01// 01-06/ 1-6 (MPO1) -> cabled to -> Panel 02// 01-06/ 1-6 <- F2B cabling to <- Panel 03// 01-06/ 1-6 (MPO1)
	     # .For Server 01// 01-06: Server 01// 01-06/ 1-6
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
    ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    
    
 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${port_list_1}[${i}]
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list_1}[${i}]->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${port_list_1}[${i}]
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list_1}[${i}]->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${port_list_1}[${i}]
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list_1}[${i}]->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 
    \    	
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SERVER_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    1
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

	# +Scheduled View: Switch 01// 01-06/ 1-6 -> patched to -> Panel 01// 01-06/ 1-6 (MPO1) -> cabled to -> Panel 02// 01-06/ 1-6 -> F2B cabling to -> Panel 03// 01-06/ 1-6 (MPO1) -> patched to -> Server 01// 01-06/ 1-6
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
 	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    6
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
    ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${port_list_1}[${i}]    
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list_1}[${i}]->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window
    
    # # 9. Complete the job above
    Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue

    # 10. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    # Step 10:
	# _Port icons for: 
	  # +Switch 01// 01-06: patched icon (including purple icon)
	  # +Panel 01-03// 01-06: cabled and patched icons
	  # +Server 01// 01-06: patched icon
	  # _Port statuses for Switch 01// 01-06, Panel 01-03// 01-06 and Server 01// 01-06: In Use
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
    Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})   
	Wait For Port Icon Change On Content Table    ${01}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDPanelCabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})   
	Wait For Port Icon Change On Content Table    ${01}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDPanelCabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}    
	Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDUncabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}  

    # _Data service is propagated on the Properties pane/window of Panel 01-03// 01-06 and Server 01// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${Data}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${Data}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Current Service}    ${Data} 	

	# _The circuit trace displays: 
	  # +Current View: like Scheduled View in step 8
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
 	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    6
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
    ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${port_list_1}[${i}]    
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list_1}[${i}]->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window
    
	# 11. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the tasks from: 
	# _Switch 01// 01-06 to Panel 01// 01-06
	# _Panel 03// 01-06 to Server 01// 01-06
	Open Patching Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
	:FOR    ${i}    IN RANGE    0    len(${port_list_1})
	 \    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})
	 ...    portsFrom=${port_list_1}[${i}]    portsTo=${port_list_1}[${i}]    typeConnect=Disconnect
	 ...    createWo=${True}    clickNext=${False}
	:FOR    ${i}    IN RANGE    0    len(${port_list_1})
	 \    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})    patchTo=${tree_node_rack}/${SERVER_NAME_1}
	 ...    portsFrom=${port_list_1}[${i}]    portsTo=${port_list_1}[${i}]    typeConnect=Disconnect
	 ...    createWo=${True}    clickNext=${False}
    Save Patching Window
    Create Work Order    ${tc_wo_name}
    
    # # 12. Observe the port statuses, the propagated services and trace horizontal and vertical them
	     # * Step 12: 
	  # _Port statuses for: 
	# +Switch 01// 01-06, Panel 01// 01-06, Panel 03// 01-06 and Server 01// 01-06: Available - Pending
	# +Panel 02// 01-06: In Use
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}

    Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}

    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}
	
    # _Data service is still propagated on the Properties pane/window of Panel 01-03// 01-06 and Server 01// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${Data}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${Data}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Current Service}    ${Data} 	
	
	# _The circuit trace displays: 
	  # +Current View: like Scheduled View in step 8
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
 	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    6
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
    ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${port_list_1}[${i}]    
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list_1}[${i}]->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window

	  # # +Scheduled View: like Current View in step 8
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
    ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    
    
 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${port_list_1}[${i}]
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list_1}[${i}]->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${port_list_1}[${i}]
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list_1}[${i}]->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${port_list_1}[${i}]
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list_1}[${i}]->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 
 	
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SERVER_NAME_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    1
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

    # 13. Complete the job above
    Open Work Order Queue Window    
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue 
	 
	# 14. Observe  the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 14: 
	# _Port icons for: 
	  # +Switch 01// 01-06: no patched icon (including purple icon)
	  # +Panel 01&03// 01-06: cabled icon and no patched icon
	  # +Panel 02// 01-06: cabled and patched icons
	  # +Server 01// 01-06: no patched icon
	# _Port statuses for: 
	  # +Switch 01// 01-06, Panel 01// 01-06, Panel 03// 01-06 and Server 01// 01-06: Available
	  # +Panel 02// 01-06: In Use
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
    Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    
	Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDPanelCabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})    
	Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDPanelCabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}    
	Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDUncabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1} 

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}    
	Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDUncabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1} 

	# _Data service is NOT propagated on the Properties pane/window of Panel 01-03// 01-06 and Server 01// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY} 	
	
	# _The circuit trace displays: 
	  # +Current View: like Current View in step 8
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
    ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    
    
 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${port_list_1}[${i}]
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list_1}[${i}]->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${port_list_1}[${i}]
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list_1}[${i}]->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_BACK_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${port_list_1}[${i}]
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list_1}[${i}]->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${Module 1A} (${DM12})/${port_list_1}[${i}]
    ...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 
    	
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SERVER_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    1
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

SM-29808_SM-29832_03-Verify that the service is propagated and trace correctly in new customer circuit: LC Switch -> patched to -> DM12 <- F2B cabling <- MPO12 Panel -> cabled 6xLC to -> LC Switch
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM-29808_SM-29832_03
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}
    
    [Tags]    SM-29808_SM-29832_SM-29833
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tc_wo_name}    Set Variable    WO_SM-29808-29832_03
    ${port_list_1}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${trace_building_name}    Set Variable    ..29808_SM-29832_03
    ${trace_tab_list_1}    Create List    1-12    2-11    3-10    4-9    5-8    6-7
    ${pair_list_1}    Create List     ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${position_list}    Set Variable     1    2    3    4    5    6
    ${trace_module_1a}    Set Variable    ..le 1A (Pass-Through)
        
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001: 
	# _LC Switch 01
	# _InstaPatch Panel 01 (DM12)
	# _MPO non-iPatch Panel 02
	# _LC Switch 02
	# 4. Set Data service for Switch 01// 01-06 directly
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME_1}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_1}    
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_NAME_1}    name=${01}    portType=${LC}
    ...    listChannel=${01}    listServiceType=${Data}    quantity=6
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_2}    
    Add Network Equipment Component    ${tree_node_rack}/${SWITCH_NAME_2}    componentType=${Network Equipment Card}    name=${CARD_NAME_1}    portType=${LC}
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (2U)}    ${PANEL_NAME_1}    ${Module 1A},True,${LC 12 Port},${DM12}
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${HD Fiber Shelf (1U)}    ${PANEL_NAME_2}    ${Module 1A},True,${MPO 2 Port},,
  
    # 5. Cable from Panel 02// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 02// 01-06
	Open Cabling Window    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})    ${01}
    Create Cabling    cableFrom=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01}    cableTo=${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}
    ...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    portsTo=${01},${02},${03},${04},${05},${06}
    Close Cabling Window
    
    # 6. F2B cabling from Panel 02// 01 (MPO12-MPO12) to Panel 01// MPO 01
    Open Front To Back Cabling Window    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})    ${01}
    Create Front To Back Cabling    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})
    ...    portsFrom=${01}    portsTo=${MPO} ${01}
    Close Front To Back Cabling Window

	# 7. Create the Add Patch job and DO NOT complete the job with the tasks from Switch 01// 01-06 to Panel 01// 01-06
	Open Patching Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
	:FOR    ${i}    IN RANGE    0    len(${port_list_1})
	 \    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})
	 ...    portsFrom=${port_list_1}[${i}]    portsTo=${port_list_1}[${i}]    createWo=${True}    clickNext=${False}
	Save Patching Window
    Create Work Order    ${tc_wo_name}

    # 8. Observe the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 8: 
	# _Port statuses for: 
	  # +Switch 01// 01-06 and Panel 01// 01-06: In Use - Pending
	  # +Switch 02// 01-06 and Panel 02// 01: In Use
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use - Pending}    ${i+1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use - Pending}    ${i+1}
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    ${1}

    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}
 
    # _Data service is NOT propagated on the Properties pane/window of Panel 01// 01-06, Panel 02// 01 and Switch 02// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through}) 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${port_list_1}[${i}]    ${EMPTY} 		

		# The circuit trace displays: 
	  # +Current View: 
	     # .For Switch 01// 01-06: Switch 01// 01-06/ 1-6
	     # .For Panel 01// 01-06, Panel 02// 01 and Switch 02// 01-06: Switch 02// 01-06/ 1 [1-1] - 6 [6-6] -> cabled to -> Panel 02// 01/ 1 [/A1] -> F2B cabling to -> Panel 01// 01-06/ 1-6 (MPO1)
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    
    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    4
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=${port_list_1}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=${1} [ /${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01} 
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window  

 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    4
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=${port_list_1}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=${1} [ /${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})    ${01}
 	:FOR    ${i}     IN RANGE    0    len(${trace_tab_list_1})
 	\    Select View Trace Tab On Site Manager    ${trace_tab_list_1}[${i}]
	\    Check Total Trace On Site Manager    4
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=${port_list_1}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=${1} [ /${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window

	# +Scheduled View: Switch 01// 01-06/ 1-6 -> patched to -> Panel 01// 01-06/ 1-6 (MPO1) <- F2B cabling to <- Panel 02// 01/ 1 [/A1] -> cabled to -> Switch 02// 01-06/ 1 [1-1] - 6 [6-6]
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
 	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    6
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
    ...    objectType=${TRACE_SWITCH_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]    
	...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_MPO12_BACK_TO_FRONT_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=${1} [ /${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=${port_list_1}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}
    \     Close Trace Window
    
    # # 9. Complete the job above
    Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue

    # 10. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 10: 
	# _Port icons for: 
	  # +Switch 01// 01-06: patched icon (including purple icon)
	  # +Panel 01// 01-06, Panel 02// 01: cabled and patched icons
	  # +Switch 02// 01-06: patched icon
	  # _Port statuses for Switch 01-02// 01-06, Panel 01// 01-06 and Panel 02// 01: In Use
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
    Wait For Port Icon Change On Content Table    ${01}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})  
	Wait For Port Icon Change On Content Table    ${01}  
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDPanelCabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through}) 
	Wait For Port Icon Change On Content Table    ${01}   
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    ${1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}  
	Wait For Port Icon Change On Content Table    ${01}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDPanelCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}  

    # _Data service is propagated on the Properties pane/window of Panel 01// 01-06, Panel 02// 01 and Switch 02// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${Data}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through}) 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${Data}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${port_list_1}[${i}]    ${Data} 

	# _The circuit trace displays:
	  # +Current View: like Scheduled View in step 8.
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
 	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    6
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    ...    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]    
	...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_MPO12_BACK_TO_FRONT_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=${1} [ /${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=${port_list_1}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}
    \     Close Trace Window
    
    # 11. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the tasks from Switch 01// 01-06 to Panel 01// 01-06    
	Open Patching Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
	:FOR    ${i}    IN RANGE    0    len(${port_list_1})
	 \    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})
	 ...    portsFrom=${port_list_1}[${i}]    portsTo=${port_list_1}[${i}]    typeConnect=Disconnect    createWo=${True}    clickNext=${False}
	Save Patching Window
    Create Work Order    ${tc_wo_name}
    
	# * Step 12: 
	# _Port statuses for: 
	  # +Switch 01// 01-06 and Panel 01// 01-06: Available - Pending
	  # +Switch 02// 01-06 and Panel 02// 01: In Use
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    ${1}

    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}
		
    # _Data service is propagated on the Properties pane/window of Panel 01// 01-06, Panel 02// 01 and Switch 02// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${Data}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through}) 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${Data}     

	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${port_list_1}[${i}]    ${Data}	
	
	# _The circuit trace displays:
	  # +Current View: like Scheduled View in step 8
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
 	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    6
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    ...    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]    
	...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_MPO12_BACK_TO_FRONT_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=${1} [ /${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=${port_list_1}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}
    \     Close Trace Window

	  # +Scheduled View: like Current View in step 8
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    
    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    4
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=${port_list_1}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=${1} [ /${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01} 
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window  

 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    4
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=${port_list_1}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=${1} [ /${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})    ${01}
    Select View Type On Trace    Scheduled
 	:FOR    ${i}     IN RANGE    0    len(${pair_list_1})
 	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]
	\    Check Total Trace On Site Manager    4
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=${port_list_1}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=${1} [ /${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window

    # 12. Complete the job above
    Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue
	 
	# 13. Observe  the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# _Port icons for: 
	  # +Switch 01// 01-06: no patched icon (including purple icon)
	  # +Panel 01// 01-06: cabled icon and no patched icon
	  # +Panel 02// 01: cabled and patched icons
	  # +Switch 02// 01-06: patched icon
	# _Port statuses for: 
	  # +Switch 01// 01-06 and Panel 01// 01-06: Available
	  # +Switch 02// 01-06 and Panel 02// 01: In Use
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}  
    Wait For Port Icon Change On Content Table    ${01}  
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})
	Wait For Port Icon Change On Content Table    ${01}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDPanelCabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})    
	Wait For Port Icon Change On Content Table    ${01}
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    ${1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}  
	Wait For Port Icon Change On Content Table    ${01}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDPanelCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}  

    # _Data service is NOT propagated on the Properties pane/window of Panel 01// 01-06, Panel 02// 01 and Switch 02// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through}) 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${port_list_1}[${i}]    ${EMPTY}		
	
	# _The circuit trace displays:
	  # +Current View: like Current View in step 8
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    
    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    4
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=${port_list_1}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=${1} [ /${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01} 
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window  

 	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    4
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=${port_list_1}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=${1} [ /${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})    ${01}
 		:FOR    ${i}     IN RANGE    0    len(${trace_tab_list_1})
 	\    Select View Trace Tab On Site Manager    ${trace_tab_list_1}[${i}]
	\    Check Total Trace On Site Manager    4
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${CARD_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=${port_list_1}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=${1} [ /${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window

SM-29808_SM-29832_04-Verify that the service is propagated and trace correctly in new customer circuit: LC Switch -> patched to -> DM12 -> cabled 6xLC to -> LC Switch
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM-29808_SM-29832_04
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}
    
    [Tags]    SM-29808_SM-29832_SM-29833
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tc_wo_name}    Set Variable    WO_SM-29808-29832_04
    ${port_list_1}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${trace_building_name}    Set Variable    ..29808_SM-29832_04
    ${trace_tab_list_1}    Create List    1-12    2-11    3-10    4-9    5-8    6-7
    ${pair_list_1}    Create List     ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${position_list}    Set Variable     1    2    3    4    5    6
        
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001: 
	# _LC Switch 01
	# _InstaPatch Panel 01 (DM12)
	# _LC Switch 02
	# 4. Set Data service for Switch 01// 01-06 directly
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME_1}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_1}    
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_NAME_1}    name=${01}    portType=${LC}
    ...    listChannel=${01}    listServiceType=${Data}    quantity=6
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_2}    
    Add Network Equipment Component    ${tree_node_rack}/${SWITCH_NAME_2}    componentType=${Network Equipment GBIC Slot}    name=${GBIC_SLOT_1}    portType=${LC}    totalPorts=6
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (2U)}    ${PANEL_NAME_1}    ${Module 1A},True,${LC 12 Port},${DM12}
  
    # 5. Cable from Panel 01// MPO 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 02// 01-06
	Open Cabling Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${01}
    Create Cabling    cableFrom=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${MPO} ${01}    cableTo=${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}
    ...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    portsTo=${01},${02},${03},${04},${05},${06}
    Close Cabling Window
    
    # 6. Create the Add Patch job and DO NOT complete the job with the tasks from Switch 01// 01-06 to Panel 01// 01-06
	Open Patching Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
	:FOR    ${i}    IN RANGE    0    len(${port_list_1})
	 \    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})
	 ...    portsFrom=${port_list_1}[${i}]    portsTo=${port_list_1}[${i}]
	 ...    createWo=${True}    clickNext=${False}
    Save Patching Window
    Create Work Order    ${tc_wo_name}
    
    # 7. Observe the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 7: 
	# _Port statuses for Switch 01// 01-06 and Panel 01// 01-06: In Use - Pending
	# _Data service is NOT propagated on the circuit.
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use - Pending}    ${i+1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use - Pending}    ${i+1}
    
	# _The circuit trace displays: 
	  # +Current View: 
	     # .For Switch 01// 01-06: Switch 01// 01-06/ 1-6
	     # .For Panel 01// 01-06 and Switch 02// 01-06: Panel 01// 01-06/ 1-6 (MPO1) -> cabled to -> Switch 02// 01-06/ 1-6
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    

 		:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

    	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

	# +Scheduled View: Switch 01// 01-06/ 1-6 -> patched to -> Panel 01// 01-06/ 1-6 (MPO1) -> cabled to -> Switch 02// 01-06/ 1-6
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
 	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    5
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
    ...    objectType=${TRACE_SWITCH_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]    
	...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}]    objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Close Trace Window
    
    # 8. Complete the job above
    Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue

    # 9. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 9: 
	# _Port icons for: 
	  # +Switch 01// 01-06: patched icon (including purple icon)
	  # +Panel 01// 01-06: cabled and patched icons
	  # +Switch 02// 01-06: patched icon
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
    Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})  
	Wait For Port Icon Change On Content Table    ${01}     
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}  
	Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDPanelCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}  
    
    # _Data service is still propagated on the Properties pane/window of Panel 01// 01-06 and Switch 02// 01-06. 
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${Data}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${port_list_1}[${i}]    ${Data}
	
	# # _The circuit trace displays:
	  # # +Current View: like Scheduled View in step 7.
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
 	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    5
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]    
	...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}]    objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Close Trace Window
    
    # 10. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the tasks from Switch 01// 01-06 to Panel 01// 01-06  
	Open Patching Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
	:FOR    ${i}    IN RANGE    0    len(${port_list_1})
	 \    Create Patching    patchFrom=${tree_node_rack}/${SWITCH_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})
	 ...  portsFrom=${port_list_1}[${i}]    portsTo=${port_list_1}[${i}]    typeConnect=Disconnect
	 ...  createWo=${True}    clickNext=${False}
    Save Patching Window
    Create Work Order    ${tc_wo_name}    
    
	# * Step 11: 
	# _Port statuses for Switch 01-02// 01-06 and Panel 01// 01-06: Available - Pending
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}
		
    # _Data service is still propagated on the Properties pane/window of Panel 01// 01-06 and Switch 02// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${Data}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${port_list_1}[${i}]    ${Data}		
	
	# # _The circuit trace displays:
	  # # +Current View: like Scheduled View in step 7
	# :FOR    ${i}     IN RANGE    0    len(${port_list_1})
 	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    5
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]    
	...    objectType=${DM12}     informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=${position_list}[${i}]    objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}
    \    Close Trace Window

	  # +Scheduled View: like Current View in step 7
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    

 		:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

    	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window
    
    # 12. Complete the job above
    Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue
	 
	# 13. Observe  the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 13: 
	# _Port icons for: 
	  # +Switch 01// 01-06: no patched icon (including purple icon)
	  # +Panel 01// 01-06: cabled icon and no patched icon
	  # +Switch 02// 01-06: patched icon
	  # _Port statuses for Switch 01-02// 01-06 and Panel 01// 01-06: Available
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
    Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})   
	Wait For Port Icon Change On Content Table    ${01}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}  
	Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDPanelCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1}  

	# _Data service is NOT propagated on the Properties pane/window of Panel 01// 01-06 and Switch 02// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12}) 
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${port_list_1}[${i}]    ${EMPTY}		
	
	# # _The circuit trace displays:
	  # # +Current View: like Current View in step 7
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    

 		:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

    	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    3
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}     
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_2}/${GBIC_SLOT_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=${position_list}[${i}] (${MPO1})   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${DM12})/${port_list_1}[${i}]   
	...    objectType=${DM12}    informationDevice=${port_list_1}[${i}]->${Module 1A} (${DM12})->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window
	
SM-29808_SM-29832_05-Verify that the service is propagated and trace correctly in customer circuit: LC Switch -> patched 6xLC to -> MPO12 Panel -> cabled to -> MPO12 Panel -> patched 6xLC to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM-29808_SM-29832_05
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}
       
    [Tags]    SM-29808_SM-29832_SM-29833
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tc_wo_name}    Set Variable    WO_SM-29808-29832_05
    ${port_list_1}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${trace_building_name}    Set Variable    ..29808_SM-29832_05
    ${pair_list_1}    Create List     ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${position_list}    Set Variable     1    2    3    4    5    6
        
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001: 
	# _LC Switch 01
	# _MPO Panel 01
	# _MPO Panel 02
	# _LC Server 01
	# 4. Set Data service for Switch 01// 01-06 directly
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME_1}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_1}    
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_NAME_1}    name=${01}    portType=${LC}
    ...    listChannel=${01}    listServiceType=${Data}    quantity=6
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_1}    portType=${MPO}    quantity=2
    Add Device In Rack    ${tree_node_rack}    ${SERVER_NAME_1}
    Add Device In Rack Port    ${tree_node_rack}/${SERVER_NAME_1}    ${01}    portType=${LC}    quantity=6
  
    # 5. Cable from Panel 01// 01 (MPO12-MPO12) to Panel 02// 01
	Open Cabling Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
    Create Cabling    cableFrom=${tree_node_rack}/${PANEL_NAME_1}/${01}    cableTo=${tree_node_rack}/${PANEL_NAME_2}
    ...    portsTo=${01}
    Close Cabling Window
    
    # 6. Create the Add Patch job and DO NOT complete the job with the tasks from: 
	# _Panel 01// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 01// 01-06
	# _Panel 02// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Server 01// 01-06
	Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}    patchTo=${tree_node_rack}/${SWITCH_NAME_1}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_2}    patchTo=${tree_node_rack}/${SERVER_NAME_1}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    createWo=${True}    clickNext=${True}
    Create Work Order    ${tc_wo_name}
    
    # 7. Observe the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 7: 
	# _Port statuses for Switch 01// 01-06, Panel 01-02// 01 and Server 01// 01-06: In Use - Pending
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use - Pending}    ${i+1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}   
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    ${1}
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    ${1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use - Pending}    ${i+1}
    # _Data service is NOT propagated on the Properties pane/window of Panel 01-02// 01 and Server 01// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    

    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY} 	

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY}		
	
	# _The circuit trace displays: 
	  # +Current View: 
	     # .For Switch 01// 01-06: Switch 01// 01-06/ 1-6
	     # .For Panel 01-02// 01: Panel 01// 01/ 1 -> cabled to -> Panel 02// 01/ 1
	     # .For Server 01// 01-06: Server 01// 01-06/ 1-6
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	Check Trace Object On Site Manager    indexObject=2    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window 

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
	Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	Check Trace Object On Site Manager    indexObject=2    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window 
    
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SERVER_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    1
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window   

	  # +Scheduled View: Switch 01// 01-06/ 1 [1-1] - 6 [6-6] -> patched to -> Panel 01// 01/ 1 [A1] -> cabled to -> Panel 02// 01/ 1 [A1] -> patched to -> Server 01// 01-06/ 1 [1-1] - 6 [6-6]
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
 	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    5
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
    ...    objectType=${TRACE_SWITCH_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=${12}    objectPosition=1 [${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=${12}    objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window
    
    # 8. Complete the job above
    Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue

    # 9. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 9: 
	# _Port icons for: 
	  # +Switch 01// 01-06: patched icon (including purple icon)
	  # +Panel 01-02// 01: cabled and patched icons
	  # +Server 01// 01-06: patched icon
	# _Port statuses for Switch 01// 01-06, Panel 01-02// 01 and Server 01// 01-06: In Use
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1} 
    Wait For Port Icon Change On Content Table    ${01}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}   
	Wait For Port Icon Change On Content Table    ${01} 
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    ${1}
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    ${1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDUncabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${In Use}    ${i+1}  

    # _Data service is propagated on the Properties pane/window of Panel 01-02// 01 and Server 01// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${Data}    

    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${Data} 	

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Current Service}    ${Data}
	
	# _The circuit trace displays:
	  # +Current View: like Scheduled View in step 7.
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
 	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    5
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=${12}    objectPosition=1 [${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=${12}    objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window
    
    # 10. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the tasks from: 
	# _Panel 01// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 01// 01-06
	# _Panel 02// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Server 01// 01-06  
	Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}    patchTo=${tree_node_rack}/${SWITCH_NAME_1}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_2}    patchTo=${tree_node_rack}/${SERVER_NAME_1}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    createWo=${True}    clickNext=${True}
    Create Work Order    ${tc_wo_name}
    
	# * Step 11: 
	# _Port statuses for Switch 01// 01-06, Panel 01-02// 01 and Server 01// 01-06: Available - Pending
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}   
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    ${1}
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    ${1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}   
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available - Pending}    ${i+1}
		
    # _Data service is still propagated on the Properties pane/window of Panel 01-02// 01 and Server 01// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${Data}    

    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${Data} 	

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Current Service}    ${Data}	

	# _The circuit trace displays:
	  # +Current View: like Scheduled View in step 7
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
 	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    5
 	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=3    mpoType=${12}    objectPosition=1 [${A1}]   objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=4    mpoType=${12}    objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window

	  # +Scheduled View: like Current View in step 7
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Select View Type On Trace    Scheduled
	Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	Check Trace Object On Site Manager    indexObject=2    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window 

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
	Select View Type On Trace    Scheduled
	Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	Check Trace Object On Site Manager    indexObject=2    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window 
    
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SERVER_NAME_1}    ${port_list_1}[${i}]
	\    Select View Type On Trace    Scheduled
	\    Check Total Trace On Site Manager    1
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 
        
    # 12. Complete the job above
    Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue
	 
	# 13. Observe  the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 13: 
	# _Port icons for: 
	  # +Switch 01// 01-06: no patched icon (including purple icon)
	  # +Panel 01-02// 01: cabled icon and no patched icon
	  # +Server 01// 01-06: no patched icon
	# _Port statuses for Switch 01// 01-06, Panel 01-02// 01 and Server 01// 01-06: Available
	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
    Wait For Port Icon Change On Content Table    ${01}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}   
	Wait For Port Icon Change On Content Table    ${01} 
	Check Icon Object Not Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}  
	Wait For Port Icon Change On Content Table    ${01}  
	Check Icon Object Not Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
	Wait For Port Icon Change On Content Table    ${01}
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Check Icon Object Not Exist On Content Pane    ${port_list_1}[${i}]    ${PortFDUncabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list_1}[${i}],${Available}    ${i+1}   

	# _Data service is NOT propagated on the Properties pane/window of Panel 01// 01-06, Panel 02// 01 and Server 01// 01-06.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    

    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY} 	

	Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_NAME_1}
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Select Object On Content Table    ${port_list_1}[${i}]
	\    Check Object Properties On Properties Pane    ${Current Service}    ${EMPTY}	

	# _The circuit trace displays:
	  # +Current View: like Current View in step 7
	:FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list_1}[${i}]->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window    

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	Check Trace Object On Site Manager    indexObject=2    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window 

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
	Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	Check Trace Object On Site Manager    indexObject=2    mpoType=${12}    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window 
    
    :FOR    ${i}     IN RANGE    0    len(${port_list_1})
	\    Open Trace Window    ${tree_node_rack}/${SERVER_NAME_1}    ${port_list_1}[${i}]
	\    Check Total Trace On Site Manager    1
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${position_list}[${i}]   objectPath=${tree_node_rack}/${SERVER_NAME_1}/${port_list_1}[${i}]    
	...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=${port_list_1}[${i}]->${SERVER_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    \    Close Trace Window 

SM-29808_SM-29832_SM-29833_16-Verify that the service is propagated and trace correctly in circuit: MPO12 Panel -> patched 6xLC-EB to -> LC Switch
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM-29808_SM-29832_16
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}
       
    [Tags]    SM-29808_SM-29832_SM-29833
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tc_wo_name}    Set Variable    WO_SM-29808-29832_16
    ${port_list_1}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${trace_building_name}    Set Variable    ..29808_SM-29832_16
    ${pair_list_1}    Create List     ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${position_list}    Set Variable     1    2    3    4    5    6
    ${1/6}    Set Variable    1/6
        
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001: 
	# _LC Switch 01
	# _MPO Panel 01
	# 4. Set Data service for Switch 01// 01-06 directly
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME_1}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_1}    
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_NAME_1}    name=${01}    portType=${LC}
    ...    listChannel=${01}    listServiceType=${Data}    quantity=6
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_1}    portType=${MPO}
  
    # 5. Create the Add Patch job and DO NOT complete the job with the task from Panel 01// 01 (MPO12-6xLC-EB)/ Pair 1 to Switch 01// 01
	Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}    patchTo=${tree_node_rack}/${SWITCH_NAME_1}
    ...    portsFrom=${01}    portsTo=${01}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1}
    ...    createWo=${True}    clickNext=${True}
    Create Work Order    ${tc_wo_name}
    
    # 6. Observe the port statuses, the propagated services and trace horizontal and vertical them
	# _Port statuses for: 
	  # +Panel 01// 01: In Use - Pending
	  # +Switch 01// 01: In Use - Pending
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}   
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    ${1}
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    ${1}
	
    # _Data service is NOT propagated on the Properties pane/window of Panel 01// 01.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    

	# _The circuit trace displays: 
	  # +Current View: 
	     # .For Panel 01// 01: Panel 01// 01/ 1
	     # .For Switch 01// 01: Switch 01// 01/ 1
	Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
    Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window    

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Check Total Trace On Site Manager    1
	Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window 
    
	    # +Scheduled View: 
     # .For Switch 01// 01 and pair 1 of Panel 01// 01: Panel 01// 01/ 1 [A1] -> patched to -> Switch 01// 01/ 1 [1-1]
     # .For other pairs of Panel 01// 01: Panel 01// 01/ 1 [A1]
 	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Select View Type On Trace    Scheduled
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1 [${Pair 1}]    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}   
    ...    objectType=${TRACE_SWITCH_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
	Check Trace Object On Site Manager    indexObject=3    mpoType=${12}   objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
     	:FOR    ${i}     IN RANGE    1    len(${pair_list_1})
 	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]
 	\    Check Total Trace On Site Manager    1
	####### \    Check Trace Object On Site Manager    indexObject=1    mpoType=None   objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	####### ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    ####### ...    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}- Defect SM-30324
    Close Trace Window
    
    # 7. Complete the job above
    Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue

    # 8. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# _Port icons for: 
	  # +Switch 01// 01: patched icon (including purple icon)
	  # +Panel 01// 01: patched icon
	# _Port statuses for: 
	  # +Panel 01// 01: In Use - 1/6
	  # +Switch 01// 01: In Use	  
	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}  
	Wait For Port Icon Change On Content Table    ${01}  
	Check Icon Object Exist On Content Pane    ${01}    ${PortNEFDServiceInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    ${1}
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1} 
	Wait For Port Icon Change On Content Table    ${01}   
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOUncabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use} - ${1/6}    ${1}

    # _Data service is propagated on the Properties pane/window of Panel 01// 01.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${Data} 
	
	# _The circuit trace displays: 
	  # +Current View: like Scheduled View in step 6.
 	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1 [${Pair 1}]    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}   
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
	Check Trace Object On Site Manager    indexObject=3    mpoType=${12}   objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
     	:FOR    ${i}     IN RANGE    1    len(${pair_list_1})
 	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]
 	\    Check Total Trace On Site Manager    1
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=None   objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Close Trace Window
    
    # 9. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the task from Panel 01// 01 (MPO12-6xLC-EB)/ Pair 1 to Switch 01// 01 
	Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}    patchTo=${tree_node_rack}/${SWITCH_NAME_1}
    ...    portsFrom=${01}    portsTo=${01}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1}
    ...    createWo=${True}    clickNext=${True}
    Create Work Order    ${tc_wo_name}
    
	# 10. Observe the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 10: 
	# _Port statuses for: 
	  # +Panel 01// 01: Available - Pending
	  # +Switch 01// 01: Available - Pending
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}   
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    ${1}
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    ${1}
	
    # _Data service is still propagated on the Properties pane/window of Panel 01// 01
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${Data}    

	# _The circuit trace displays: 
	  # +Current View: like Scheduled View in step 6
 	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1 [${Pair 1}]    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}   
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
	Check Trace Object On Site Manager    indexObject=3    mpoType=${12}   objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
     	:FOR    ${i}     IN RANGE    1    len(${pair_list_1})
 	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]
 	\    Check Total Trace On Site Manager    1
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=${12}   objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    ...    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Close Trace Window

	  # +Scheduled View: like Current View in step 6
	Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
	Select View Type On Trace    Scheduled
    Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window    

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Select View Type On Trace    Scheduled
	Check Total Trace On Site Manager    1
	Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
        
    # 11. Complete the job above
    Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue
	 
	# 12. Observe  the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 12: 
	# _Port icons for: 
	  # +Switch 01// 01: no patched icon (including purple icon)
	  # +Panel 01// 01: no patched icon
	# _Port statuses for: 
	  # +Panel 01// 01: Available
	  # +Switch 01// 01: Available
	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1} 
	Wait For Port Icon Change On Content Table    ${01}   
	Check Icon Object Not Exist On Content Pane    ${01}    ${PortNEFDServiceInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1} 
	Wait For Port Icon Change On Content Table    ${01}   
	Check Icon Object Not Exist On Content Pane    ${01}    ${PortMPOUncabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}

    # _Data service is NOT propagated on the Properties pane/window of Panel 01// 01.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY}

    # _The circuit trace displays: 
      # +Current View: like Current View in step 6
	Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
    Check Total Trace On Site Manager    2
	Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window    

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Check Total Trace On Site Manager    1
	Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window 

SM-29808_SM-29832_SM-29833_17-Verify that the service is propagated and trace correctly in circuit: MPO12 Panel -> F2B cabling 6xLC-EB to -> LC Panel
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM-29808_SM-29832_17
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}
    
    [Tags]    SM-29808_SM-29832_SM-29833
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tc_wo_name}    Set Variable    WO_SM-29808-29832_17
    ${trace_building_name}    Set Variable    ..29808_SM-29832_17
    ${pair_list_1}    Create List     ${Pair 1}    ${Pair 2}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${1/6}    Set Variable    1/6
    
	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add to Rack 001: 
	# _MPO Panel 01
	# _LC Panel 02
	# 4. Set Data service for Panel 01// 01 directly
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME_1}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}    ${RACK_NAME}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_1}    portType=${MPO}    service=${Data}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_2}    portType=${LC}
      
    # 5. F2B cabling from Panel 01// 01 (MPO126xLC-EB)/Pair 3 to Panel 02// 01
	Open Front To Back Cabling Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
    Create Front To Back Cabling    cabFrom=${tree_node_rack}/${PANEL_NAME_1}    cabTo=${tree_node_rack}/${PANEL_NAME_2}
    ...    portsFrom=${01}    portsTo=${01}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 3}
    Close Front To Back Cabling Window
    
    # 6. Observe the port statuses, the propagated services and trace horizontal and vertical them
	# _Port icons for: 
	  # +Panel 01// 01: patched icon (including purple icon)
	  # +Panel 02// 01: patched icon
	# _Port statuses for: 
	  # +Panel 01// 01: In Use - 1/6
	  # +Panel 02// 01: Available
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}    
	Wait For Port Icon Change On Content Table    ${01}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortFDPanelCabledAvailable}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}    
	Wait For Port Icon Change On Content Table    ${01}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use} - ${1/6}    ${1}
	
    # _Data service is propagated on the Properties pane/window of Panel 02// 01.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${Data}    

	# _The circuit trace displays: 
	  # +Current View: 
	     # .For Panel 02// 01 and pair 1 of Panel 01// 01: Panel 01// 01/ 1 [A1] -> F2B cabling to -> Panel 02// 01/ 1 [/3-3]
	     # .For other pairs of Panel 01// 01: Panel 01// 01/ 1 [A1]
 	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Select View Trace Tab On Site Manager    ${Pair 3}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	Check Trace Object On Site Manager    indexObject=2    mpoType=${12}   objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1 [ /${Pair 3}]    objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}   
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}

     :FOR    ${i}     IN RANGE    0    len(${pair_list_1})
    \    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]
    \    Check Total Trace On Site Manager    2
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=${12}   objectPosition=1 [${A1}]    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    ...    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING}
    Close Trace Window
    
    # 7. Remove F2B cabling from Panel 01// 01 (MPO12-6xLC-EB)/Pair 3 to Panel 02// 01 
	Open Front To Back Cabling Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
    Create Front To Back Cabling    cabFrom=${tree_node_rack}/${PANEL_NAME_1}    cabTo=${tree_node_rack}/${PANEL_NAME_2}
    ...    portsFrom=${01}    portsTo=${01}    typeConnect=DisConnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 3}
    Close Front To Back Cabling Window
    
	# 8. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# _Port icons for: 
	  # +Panel 01// 01: no patched icon (including purple icon)
	  # +Panel 02// 01: no patched icon
	# _Port statuses for: 
	  # +Panel 01// 01: Available
	  # +Panel 02// 01: Available
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}    
	Wait For Port Icon Change On Content Table    ${01}     
	Check Icon Object Not Exist On Content Pane    ${01}    ${PortFDPanelCabledAvailable}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}  
	Wait For Port Icon Change On Content Table    ${01}       
	Check Icon Object Not Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}
	
    # _Data service is NOT propagated on the Properties pane/window of Panel 02// 01.
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    

	# _The circuit trace displays: 
	  # +Current View: 
	# _Panel 01// 01: Panel 01// 01(service)
	# _Panel 02// 01: Panel 02// 01
 	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Check Total Trace On Site Manager    2
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}    
 	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
	Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01}   
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
SM-29808_SM-29832_SM-29833_14_Verify that the service is propagated and trace correctly in circuit: RJ-45 Switch -> cabled to -> RJ-45 Panel -> patched to -> MC - MC -> F2B cabling to -> LC Panel -> patched 6xLC-EB to -> MPO12 Panel
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM-29808_SM-29832_14
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building     ${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}
       
    [Tags]    SM-29808_SM-29832_SM-29833
    
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${tc_wo_name}    Set Variable    WO_SM-29808-29832_14
    ${port_list_1}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${trace_building_name}    Set Variable    ..29808_SM-29832_14
    ${trace_tab_list_1}    Create List    1-12    2-11    3-10    4-9    5-8    6-7
    ${pair_list_1}    Create List     ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${position_list}    Set Variable     1    2    3    4    5    6
    ${trace_module_1a}    Set Variable    ..le 1A (Pass-Through)   
    ${1/6}    Set Variable    1/6
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
    # 3. Add to Rack 001: 
    # _RJ-45 Switch 01
    # _RJ-45 non-iPatch Panel 01
    # _Media Converter 01
    # _LC Panel 02
    # _MPO Panel 03
    # _LC Panel 04
    # 4. Set Data service for Switch 01// 01 directly
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME_1}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME_1}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${tree_node_rack}    ${SWITCH_NAME_1}
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}    ${RJ-45}    listChannel=${01}    listServiceType=${Data}    
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_1}    portType=${RJ-45}
    Add Media Converter    ${tree_node_rack}    ${MEDIA_CONVERTER_NAME}    
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_2}    portType=${LC}    
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_3}    portType=${MPO}    
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_4}    portType=${LC}
    # 5. Cable from Switch 01// 01 to Panel 01// 01
    Open Cabling Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
    Create Cabling    Connect    ${tree_node_rack}/${SWITCH_NAME_1}/${01}    ${tree_node_rack}/${PANEL_NAME_1}    portsTo=01
    Close Cabling Window
	# 6. Create the Add Patch job and DO NOT complete the job with the tasks from: 
	# _Panel 01// 01 to Media Converter 01/ 01 Copper
	# _Panel 03// 01 (MPO12-6xLC-EB)/ Pair 1 to Panel 02// 01
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
    Create Patching    ${tree_node_rack}/${PANEL_NAME_1}    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}   ${01}    ${01} ${Copper}    clickNext=${False}        
    Create Patching    ${tree_node_rack}/${PANEL_NAME_3}    ${tree_node_rack}/${PANEL_NAME_2}   ${01}    ${01}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1}
    Create Work Order    ${tc_wo_name}
    # 7. F2B cabling from Media Converter 01/ 01 Fiber to Panel 02// 01
    Open Front To Back Cabling Window    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    ${01} ${Fiber}
    Create Front To Back Cabling    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    ${tree_node_rack}/${PANEL_NAME_2}    ${01} ${Fiber}    01    
    Close Front To Back Cabling Window   
    # 8. Observe the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 8: 
	# _Port statuses for: 
	  # +Switch 01// 01, Panel 01-02// 01 and Media Converter 01/ 01 Copper : In Use - Pending
	  # +Panel 03// 01: In Use - Pending
	  # +Media Converter 01/ 01 Fiber: In Use
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    ${1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    ${1}

    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    ${1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01} ${Copper},${In Use - Pending}    ${1}
		    
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - Pending}    ${1}
 
    Click Tree Node On Site Manager    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01} ${Fiber},${In Use}    ${2}

    # _Data service is NOT propagated on the Properties pane/window of Panel 02-03// 01.   
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY}  
	  
	# _The circuit trace displays: 
	  # +Current View: 
	     # .For Switch 01// 01 and Panel 01// 01: Switch 01// 01/ 1 -> cabled to -> Panel  01// 01/ 1
	Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}    
	...    objectType=${TRACE_SWITCH_IMAGE}     informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window 

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}    
	...    objectType=${TRACE_SWITCH_IMAGE}     informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window     

    # .For Media Converter 01/ 01 Copper & 01 Fiber and Panel 02// 01: Media Converter 01/ 01 Copper/ 1 -> connected to -> Media Converter 01/ 01 Fiber/ 2 -> F2B cabling to -> Panel 02// 01/ 1    
	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01} 
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_FIBER_BACK_TO_FRONT_CABLING}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Fiber}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}     informationDevice=${01} ${Fiber}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Copper}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Copper}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
	Open Trace Window    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    ${01} ${Fiber}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01} 
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_FIBER_BACK_TO_FRONT_CABLING}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Fiber}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}     informationDevice=${01} ${Fiber}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Copper}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Copper}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window

	Open Trace Window    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    ${01} ${Copper}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01} 
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_FIBER_BACK_TO_FRONT_CABLING}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Fiber}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}     informationDevice=${01} ${Fiber}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Copper}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Copper}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
	# .For Panel 03// 01: Panel 03// 01/ 1
	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_3}    ${01}
	Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${01} 
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	
	# +Scheduled View: Switch 01// 01/ 1 -> cabled to -> Panel  01// 01/ 1 -> patched to -> Media Converter 01/ 01 Copper/ 1 -> connected to -> Media Converter 01/ 01 Fiber/ 2 -> F2B cabling to -> Panel 02// 01/ 1 [1-1] -> patched to -> Panel 03// 01/ 1 [A1]
	Select View Type On Trace    Scheduled
	Check Total Trace On Site Manager    7
	Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}    
	...    objectType=${TRACE_SWITCH_IMAGE}     informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    ...    connectionType=${TRACE_COPPER_PATCHING}
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Copper}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Copper}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    ...    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=2    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Fiber}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Fiber}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=1 [${Pair 1}]     objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01} 
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}	
    Check Trace Object On Site Manager    indexObject=7    mpoType=12    objectPosition=1 [${A1}]     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${01} 
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
    # 9. Complete the job above
    Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue
    # 10. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# * Step 10: 
	# _Port icons for: 
	  # +Switch 01// 01: patched icon (including purple icon)
	  # +Panel 01// 01: cabled and patched icons (including purple icon)
	  # +Panel 02// 01: cabled and patched icons
	  # +Panel 03// 01: patched icon
	  # +Media Converter 01/ 01 Copper: cabled and patched icons
	  # +Media Converter 01/ 01 Fiber: cabled and patched icons
	# _Port statuses for: 
	  # +Switch 01// 01, Panel 01-02// 01 and Media Converter 01/ 01 Copper & 01 Fiber: In Use
	  # +Panel 03// 01: In Use - 1/6    
	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	Wait For Port Icon Change On Content Table    ${01}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortNECServiceCabled}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    ${1}
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}    
	Wait For Port Icon Change On Content Table    ${01}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortNECServiceInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    ${1}	 

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortFDPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    ${1}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3}    
	Wait For Port Icon Change On Content Table    ${01}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOUncabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use} - ${1/6}    ${1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    
	Wait For Port Icon Change On Content Table    ${01} ${Copper}   
	Check Icon Object Exist On Content Pane    ${01} ${Copper}    ${PortCPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01} ${Copper},${In Use}    ${1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    
	Wait For Port Icon Change On Content Table    ${01} ${Fiber} 
	Check Icon Object Exist On Content Pane    ${01} ${Fiber}    ${PortFDPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01} ${Fiber},${In Use}    ${2}
	
    # _Data service is propagated on the Properties pane/window of Panel 02-03// 01.
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${Data}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${Data}

	# _The circuit trace displays: 
	  # +Current View: like Scheduled View in step 8
	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_3}    ${01}
	Check Total Trace On Site Manager    7
	Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}    
	...    objectType=${TRACE_SWITCH_IMAGE}     informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    ...    connectionType=${TRACE_COPPER_PATCHING}
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Copper}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Copper}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    ...    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=2    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Fiber}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Fiber}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=1 [${Pair 1}]     objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01} 
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}	
    Check Trace Object On Site Manager    indexObject=7    mpoType=12    objectPosition=1 [${A1}]     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${01} 
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
  	Close Trace Window
  	    
    # 11. Create the Remove Patch job (or Remove Circuit) and DO NOT complete the job with the tasks from: 
    # _Panel 01// 01 to Media Converter 01/ 01 Copper
    # _Panel 03// 01 (MPO12-6xLC-EB)/Pair 1 to Panel 02// 01
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
    Create Patching    ${tree_node_rack}/${PANEL_NAME_1}    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}   ${01}    ${01} ${Copper}    typeConnect=Disconnect    clickNext=${False}        
    Create Patching    ${tree_node_rack}/${PANEL_NAME_3}    ${tree_node_rack}/${PANEL_NAME_2}   ${01}    ${01}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1}
    Create Work Order    ${tc_wo_name}   

    # 12. Observe the port statuses, the propagated services and trace horizontal and vertical them
    # * Step 12: 
	# _Port statuses for: 
	  # +Switch 01// 01, Panel 01-02// 01 and Media Converter 01/ 01 Copper: Available - Pending
	  # +Panel 03// 01: Available - Pending
	  # +Media Converter 01/ 01 Fiber: In Use
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}   
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    ${1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    ${1}

    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    ${1}
	
    Click Tree Node On Site Manager    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01} ${Copper},${Available - Pending}    ${1}
		    
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}    ${1}
 
    Click Tree Node On Site Manager    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01} ${Fiber},${In Use}    ${2}	

	# _The circuit trace displays: 
	  # +Current View: like Scheduled View in step 8
    Open Trace Window    ${tree_node_rack}/${PANEL_NAME_3}    ${01}
	Check Total Trace On Site Manager    7
	Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}    
	...    objectType=${TRACE_SWITCH_IMAGE}     informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    ...    connectionType=${TRACE_COPPER_PATCHING}
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Copper}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Copper}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    ...    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=2    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Fiber}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Fiber}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=1 [${Pair 1}]     objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01} 
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}	
    Check Trace Object On Site Manager    indexObject=7    mpoType=12    objectPosition=1 [${A1}]     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${01} 
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
	  # +Scheduled View: like Current View in step 8
	Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
	Select View Type On Trace    Scheduled
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}    
	...    objectType=${TRACE_SWITCH_IMAGE}     informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window 

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Select View Type On Trace    Scheduled
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}    
	...    objectType=${TRACE_SWITCH_IMAGE}     informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window     

    # .For Media Converter 01/ 01 Copper & 01 Fiber and Panel 02// 01: Media Converter 01/ 01 Copper/ 1 -> connected to -> Media Converter 01/ 01 Fiber/ 2 -> F2B cabling to -> Panel 02// 01/ 1    
	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
	Select View Type On Trace    Scheduled
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01} 
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_FIBER_BACK_TO_FRONT_CABLING}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Fiber}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}     informationDevice=${01} ${Fiber}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Copper}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Copper}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
	Open Trace Window    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    ${01} ${Fiber}
	Select View Type On Trace    Scheduled
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01} 
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_FIBER_BACK_TO_FRONT_CABLING}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Fiber}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}     informationDevice=${01} ${Fiber}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Copper}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Copper}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window

	Open Trace Window    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    ${01} ${Copper}
	Select View Type On Trace    Scheduled
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01} 
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_FIBER_BACK_TO_FRONT_CABLING}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Fiber}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}     informationDevice=${01} ${Fiber}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Copper}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Copper}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
	# .For Panel 03// 01: Panel 03// 01/ 1
	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_3}    ${01}
	Select View Type On Trace    Scheduled
	Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${01} 
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	Close Trace Window
	
    # 13. Complete the job above
    Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue    

    # 14. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	    # _Port icons for: 
	  # +Switch 01// 01: patched icon (including purple icon)
	  # +Panel 01// 01: cabled icon and no patched icon (including purple icon)
	  # +Panel 02// 01: cabled icon and no patched icon
	  # +Panel 03// 01: no patched icon
	  # +Media Converter 01/ 01 Copper: cabled icon and no patched icon
	  # +Media Converter 01/ 01 Fiber: cabled and patched icons
	# _Port statuses for: 
	  # +Switch 01// 01, Panel 01-02// 01 and Media Converter 01/ 01 Copper & 01 Fiber: Available
	  # +Panel 03// 01: Available
	Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME_1}    
	Wait For Port Icon Change On Content Table    ${01}    
	Check Icon Object Exist On Content Pane    ${01}    ${PortNECServiceCabled}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}
	
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}   
	Wait For Port Icon Change On Content Table    ${01}     
	Check Icon Object Not Exist On Content Pane    ${01}    ${PortNECServiceInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}	 

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}    
	Wait For Port Icon Change On Content Table    ${01}    
	Check Icon Object Not Exist On Content Pane    ${01}    ${PortFDPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3}  
	Wait For Port Icon Change On Content Table    ${01}      
	Check Icon Object Not Exist On Content Pane    ${01}    ${PortMPOUncabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${MEDIA_CONVERTER_NAME} 
	Wait For Port Icon Change On Content Table    ${01} ${Copper}      
	Check Icon Object Not Exist On Content Pane    ${01} ${Copper}    ${PortCPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01} ${Copper},${Available}    ${1}

	Click Tree Node On Site Manager    ${tree_node_rack}/${MEDIA_CONVERTER_NAME} 
	Wait For Port Icon Change On Content Table       ${01} ${Fiber}
	Check Icon Object Exist On Content Pane    ${01} ${Fiber}    ${PortFDPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01} ${Fiber},${In Use}    ${2}
 
    # _Data service is NOT propagated on the Properties pane/window of Panel 02-03// 01.
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY}    

	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_3} 
	Select Object On Content Table    ${01}
	Check Object Properties On Properties Pane    ${Service}    ${EMPTY}
	
	# _The circuit trace displays: 
      # +Current View: like Current View in step 8
	Open Trace Window    ${tree_node_rack}/${SWITCH_NAME_1}    ${01}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}    
	...    objectType=${TRACE_SWITCH_IMAGE}     informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window 

	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE} ${Data}
	...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->${Data}->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${SWITCH_NAME_1}/${01}    
	...    objectType=${TRACE_SWITCH_IMAGE}     informationDevice=${01}->${SWITCH_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}    
	...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window     

    # .For Media Converter 01/ 01 Copper & 01 Fiber and Panel 02// 01: Media Converter 01/ 01 Copper/ 1 -> connected to -> Media Converter 01/ 01 Fiber/ 2 -> F2B cabling to -> Panel 02// 01/ 1    
	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_2}    ${01}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01} 
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_FIBER_BACK_TO_FRONT_CABLING}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Fiber}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}     informationDevice=${01} ${Fiber}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Copper}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Copper}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
	Open Trace Window    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    ${01} ${Fiber}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01} 
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_FIBER_BACK_TO_FRONT_CABLING}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Fiber}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}     informationDevice=${01} ${Fiber}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Copper}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Copper}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window

	Open Trace Window    ${tree_node_rack}/${MEDIA_CONVERTER_NAME}    ${01} ${Copper}
	Check Total Trace On Site Manager    3
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${tree_node_rack}/${PANEL_NAME_2}/${01} 
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
	...    connectionType=${TRACE_FIBER_BACK_TO_FRONT_CABLING}	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Fiber}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}     informationDevice=${01} ${Fiber}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
	...    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${tree_node_rack}/${MEDIA_CONVERTER_NAME}/${01} ${Copper}
	...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=${01} ${Copper}->${MEDIA_CONVERTER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}
    Close Trace Window
    
	# .For Panel 03// 01: Panel 03// 01/ 1
	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_3}    ${01}
	Check Total Trace On Site Manager    1
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${tree_node_rack}/${PANEL_NAME_3}/${01} 
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${trace_building_name}->${SITE_NODE}    
    Close Trace Window