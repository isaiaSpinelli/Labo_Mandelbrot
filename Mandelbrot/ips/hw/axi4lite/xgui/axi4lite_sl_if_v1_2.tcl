# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_AXI4_ADDR_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI4_ARADDR_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI4_AWADDR_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI4_BRESP_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI4_DATA_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI4_RDATA_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI4_RRESP_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI4_WDATA_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI4_WSTRB_SIZE" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_AXI4_ADDR_SIZE { PARAM_VALUE.C_AXI4_ADDR_SIZE } {
	# Procedure called to update C_AXI4_ADDR_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_ADDR_SIZE { PARAM_VALUE.C_AXI4_ADDR_SIZE } {
	# Procedure called to validate C_AXI4_ADDR_SIZE
	return true
}

proc update_PARAM_VALUE.C_AXI4_ARADDR_SIZE { PARAM_VALUE.C_AXI4_ARADDR_SIZE } {
	# Procedure called to update C_AXI4_ARADDR_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_ARADDR_SIZE { PARAM_VALUE.C_AXI4_ARADDR_SIZE } {
	# Procedure called to validate C_AXI4_ARADDR_SIZE
	return true
}

proc update_PARAM_VALUE.C_AXI4_AWADDR_SIZE { PARAM_VALUE.C_AXI4_AWADDR_SIZE } {
	# Procedure called to update C_AXI4_AWADDR_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_AWADDR_SIZE { PARAM_VALUE.C_AXI4_AWADDR_SIZE } {
	# Procedure called to validate C_AXI4_AWADDR_SIZE
	return true
}

proc update_PARAM_VALUE.C_AXI4_BRESP_SIZE { PARAM_VALUE.C_AXI4_BRESP_SIZE } {
	# Procedure called to update C_AXI4_BRESP_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_BRESP_SIZE { PARAM_VALUE.C_AXI4_BRESP_SIZE } {
	# Procedure called to validate C_AXI4_BRESP_SIZE
	return true
}

proc update_PARAM_VALUE.C_AXI4_DATA_SIZE { PARAM_VALUE.C_AXI4_DATA_SIZE } {
	# Procedure called to update C_AXI4_DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_DATA_SIZE { PARAM_VALUE.C_AXI4_DATA_SIZE } {
	# Procedure called to validate C_AXI4_DATA_SIZE
	return true
}

proc update_PARAM_VALUE.C_AXI4_RDATA_SIZE { PARAM_VALUE.C_AXI4_RDATA_SIZE } {
	# Procedure called to update C_AXI4_RDATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_RDATA_SIZE { PARAM_VALUE.C_AXI4_RDATA_SIZE } {
	# Procedure called to validate C_AXI4_RDATA_SIZE
	return true
}

proc update_PARAM_VALUE.C_AXI4_RRESP_SIZE { PARAM_VALUE.C_AXI4_RRESP_SIZE } {
	# Procedure called to update C_AXI4_RRESP_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_RRESP_SIZE { PARAM_VALUE.C_AXI4_RRESP_SIZE } {
	# Procedure called to validate C_AXI4_RRESP_SIZE
	return true
}

proc update_PARAM_VALUE.C_AXI4_WDATA_SIZE { PARAM_VALUE.C_AXI4_WDATA_SIZE } {
	# Procedure called to update C_AXI4_WDATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_WDATA_SIZE { PARAM_VALUE.C_AXI4_WDATA_SIZE } {
	# Procedure called to validate C_AXI4_WDATA_SIZE
	return true
}

proc update_PARAM_VALUE.C_AXI4_WSTRB_SIZE { PARAM_VALUE.C_AXI4_WSTRB_SIZE } {
	# Procedure called to update C_AXI4_WSTRB_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI4_WSTRB_SIZE { PARAM_VALUE.C_AXI4_WSTRB_SIZE } {
	# Procedure called to validate C_AXI4_WSTRB_SIZE
	return true
}


proc update_MODELPARAM_VALUE.C_AXI4_ARADDR_SIZE { MODELPARAM_VALUE.C_AXI4_ARADDR_SIZE PARAM_VALUE.C_AXI4_ARADDR_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_ARADDR_SIZE}] ${MODELPARAM_VALUE.C_AXI4_ARADDR_SIZE}
}

proc update_MODELPARAM_VALUE.C_AXI4_RDATA_SIZE { MODELPARAM_VALUE.C_AXI4_RDATA_SIZE PARAM_VALUE.C_AXI4_RDATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_RDATA_SIZE}] ${MODELPARAM_VALUE.C_AXI4_RDATA_SIZE}
}

proc update_MODELPARAM_VALUE.C_AXI4_RRESP_SIZE { MODELPARAM_VALUE.C_AXI4_RRESP_SIZE PARAM_VALUE.C_AXI4_RRESP_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_RRESP_SIZE}] ${MODELPARAM_VALUE.C_AXI4_RRESP_SIZE}
}

proc update_MODELPARAM_VALUE.C_AXI4_AWADDR_SIZE { MODELPARAM_VALUE.C_AXI4_AWADDR_SIZE PARAM_VALUE.C_AXI4_AWADDR_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_AWADDR_SIZE}] ${MODELPARAM_VALUE.C_AXI4_AWADDR_SIZE}
}

proc update_MODELPARAM_VALUE.C_AXI4_WDATA_SIZE { MODELPARAM_VALUE.C_AXI4_WDATA_SIZE PARAM_VALUE.C_AXI4_WDATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_WDATA_SIZE}] ${MODELPARAM_VALUE.C_AXI4_WDATA_SIZE}
}

proc update_MODELPARAM_VALUE.C_AXI4_WSTRB_SIZE { MODELPARAM_VALUE.C_AXI4_WSTRB_SIZE PARAM_VALUE.C_AXI4_WSTRB_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_WSTRB_SIZE}] ${MODELPARAM_VALUE.C_AXI4_WSTRB_SIZE}
}

proc update_MODELPARAM_VALUE.C_AXI4_BRESP_SIZE { MODELPARAM_VALUE.C_AXI4_BRESP_SIZE PARAM_VALUE.C_AXI4_BRESP_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_BRESP_SIZE}] ${MODELPARAM_VALUE.C_AXI4_BRESP_SIZE}
}

proc update_MODELPARAM_VALUE.C_AXI4_DATA_SIZE { MODELPARAM_VALUE.C_AXI4_DATA_SIZE PARAM_VALUE.C_AXI4_DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_DATA_SIZE}] ${MODELPARAM_VALUE.C_AXI4_DATA_SIZE}
}

proc update_MODELPARAM_VALUE.C_AXI4_ADDR_SIZE { MODELPARAM_VALUE.C_AXI4_ADDR_SIZE PARAM_VALUE.C_AXI4_ADDR_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI4_ADDR_SIZE}] ${MODELPARAM_VALUE.C_AXI4_ADDR_SIZE}
}

