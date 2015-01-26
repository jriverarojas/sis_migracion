﻿<?php
/**
 *@package   pXP
 *@file      TsLibroBancosDeposito.php
 *@author    Gonzalo Sarmiento Sejas
 *@date      13-11-2012 01:30:22
 *@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
 */
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
	Phx.vista.TsLibroBancosDeposito = Ext.extend(Phx.gridInterfaz, {
		
		constructor : function(config) {
			this.maestro = config.maestro;
			Phx.vista.TsLibroBancosDeposito.superclass.constructor.call(this, config);
			this.init();
			this.iniciarEventos();
			this.store.baseParams={
					id_cuenta_bancaria : this.id_cuenta_bancaria,
					mycls:this.mycls};
			this.load({
				params : {
					start : 0,
					limit : 50
				}
			});
			this.Atributos[1].valorInicial = this.id_cuenta_bancaria;
			this.Atributos[16].config.store.baseParams.id_cuenta_bancaria =this.id_cuenta_bancaria;		
			
			this.addButton('btnClonar',
				{
					text: 'Clonar',
					iconCls: 'bdocuments',
					disabled: false,
					handler: this.clonar,
					tooltip: '<b>Clonar</b><br/>Clonar Registro'
				}
			);
			
			this.addButton('btnReporteDeposito',
				{
					text: 'Reporte Deposito',
					iconCls: 'bexcel',
					disabled: false,
					handler: this.reporteDeposito,
					tooltip: '<b>Reporte Deposito</b><br/>Reporte Completo Deposito'
				}
			);
			
			this.addButton('fin_registro',
				{	text:'Siguiente',
					iconCls: 'badelante',
					disabled:false,
					handler:this.sigEstado,
					tooltip: '<b>Siguiente</b><p>Pasa al siguiente estado, si esta en borrador pasara a depositado</p>'
				}
			);
		},
		Atributos : [{
			config : {
				labelSeparator : '',
				inputType : 'hidden',
				name : 'id_libro_bancos'
			},
			type : 'Field',
			form : true
		}, {
			config : {
				labelSeparator : '',
				inputType : 'hidden',
				name : 'id_cuenta_bancaria'
			},
			type : 'Field',
			form : true
		},
		{
            config:{
                name: 'id_depto',
                fieldLabel: 'Depto',
                allowBlank: false,
                anchor: '80%',
                origen: 'DEPTO',
                tinit: false,
                baseParams:{tipo_filtro:'DEPTO_UO',estado:'activo',codigo_subsistema:'TES'},//parametros adicionales que se le pasan al store
                gdisplayField:'nombre',
                gwidth: 100
            },
            type:'ComboRec',
            filters:{pfiltro:'dep.nombre',type:'string'},
            id_grupo:1,
            grid:false,
            form:true
        },
		{
			config:{
				name: 'fecha',
				fieldLabel: 'Fecha',
				allowBlank: false,
				anchor: '80%',
				gwidth: 80,
				format: 'd/m/Y', 
				renderer:function (value,p,record){
					//return value?value.dateFormat('d/m/Y'):''}
					return String.format('{0}', '<FONT COLOR="'+record.data['color']+'"><b>'+value.dateFormat('d/m/Y')+'</b></FONT>');
				}
			},
			type:'DateField',
			filters:{pfiltro:'lban.fecha',type:'date'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'a_favor',
				fieldLabel: 'A Favor',
				allowBlank: false,
				anchor: '80%',
				gwidth: 150,
				maxLength:100,
				renderer : function (value, p, record){		
					if(record.data['saldo_deposito']==0)					
						return String.format('{0}', '<h2 style="background-color:#B9BBC9;"><b>'+value+'</b></h2>');
					else
						return String.format('{0}', value);
				}
			},
			type:'TextField',
			filters:{pfiltro:'lban.a_favor',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'detalle',
				fieldLabel: 'Detalle',
				allowBlank: false,
				anchor: '80%',
				gwidth: 150,
				maxLength:200,				
				renderer : function (value, p, record){		
					if(record.data['saldo_deposito']==0)					
						return String.format('{0}', '<h2 style="background-color:#B9BBC9;"><b>'+value+'</b></h2>');
					else
						return String.format('{0}', value);
				}
			},
			type:'TextArea',
			filters:{pfiltro:'lban.detalle',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'observaciones',
				fieldLabel: 'Observaciones',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:200
			},
			type:'TextArea',
			filters:{pfiltro:'lban.observaciones',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'nro_liquidacion',
				fieldLabel: 'Nro Liquidacion',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:20
			},
			type:'TextField',
			filters:{pfiltro:'lban.nro_liquidacion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'nro_comprobante',
				fieldLabel: 'Nro Comprobante',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:20
			},
			type:'TextField',
			filters:{pfiltro:'lban.nro_comprobante',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'tipo',
				fieldLabel:'Tipo',
				allowBlank:false,
				emptyText:'Tipo...',
				typeAhead: true,
				triggerAction: 'all',
				lazyRender:true,
				mode: 'local',
				valueField: 'estilo',
				gwidth: 70,
				store:new Ext.data.ArrayStore({
                            fields: ['variable', 'valor'],
                            data : [ ['deposito','Depósito']
                                    ]
                                    }),
				valueField: 'variable',
				displayField: 'valor'
			},
			type:'ComboBox',
			valorInicial:'deposito',
			id_grupo:1,
			filters:{	
					 type: 'list',
					  pfiltro:'lban.tipo',
					 options: ['deposito'],	
				},
			grid:true,
			form:true
		},
		{
			config:{
				name: 'nro_cheque',
				fieldLabel: 'Nro Cheque',
				allowBlank: true,
				anchor: '80%',
				gwidth: 90,
				maxLength:4
			},
				type:'NumberField',
				filters:{pfiltro:'lban.nro_cheque',type:'numeric'},
				id_grupo:1,
				grid:false,
				form:true
		},
		{
			config:{
				name: 'importe_deposito',
				fieldLabel: 'Importe Depósito',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength:1310722
			},
				type:'NumberField',
				filters:{pfiltro:'lban.importe_deposito',type:'numeric'},
				id_grupo:1,
				valorInicial:0,
				grid:true,
				form:true
		},	
		{
			config:{
				name: 'importe_cheque',
				fieldLabel: 'Importe Cheque',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength:1310722
			},
				type:'NumberField',
				filters:{pfiltro:'lban.importe_cheque',type:'numeric'},
				id_grupo:1,
				valorInicial:0,
				grid:false,
				form:true
		},
		{
			config:{
				name: 'saldo_deposito',
				fieldLabel: 'Saldo Depósito',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength:1310722
			},
				type:'NumberField',
				filters:{pfiltro:'saldo_deposito',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name:'origen',
				fieldLabel:'Origen',
				allowBlank:false,
				emptyText:'Tipo...',
				typeAhead: true,
				triggerAction: 'all',
				lazyRender:true,
				mode: 'local',
				valueField: 'estilo',
				gwidth: 60,
				store:['CBB','SRZ','LPB','TJA','SRE','CIJ','TDD','UYU']
			},
			type:'ComboBox',
			id_grupo:1,
			filters:{	
					 type: 'list',
					  pfiltro:'lban.origen',
					 options: ['CBB','SRZ','TJA','SRE','CIJ','TDD','UYU'],	
				},
			grid:true,
			form:true
		},
		{
			config:{
				name: 'estado',
				fieldLabel: 'Estado',
				allowBlank: false,
				anchor: '80%',
				gwidth: 80,
				maxLength:20
			},
				type:'TextField',
				filters:{pfiltro:'lban.estado',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
            config:{
                name:'id_finalidad',
                fieldLabel:'Finalidad',
                allowBlank:false,
                emptyText:'Finalidad...',
                store: new Ext.data.JsonStore({
                         url: '../../sis_tesoreria/control/Finalidad/listarFinalidadCuentaBancaria',
                         id: 'id_finalidad',
                         root: 'datos',
                         sortInfo:{
                            field: 'nombre_finalidad',
                            direction: 'ASC'
                    },
                    totalProperty: 'total',
                    fields: ['id_finalidad','nombre_finalidad','color'],
                    // turn on remote sorting
                    remoteSort: true,
                    baseParams:{par_filtro:'nombre_finalidad', vista: 'vista'}
                    }),
                valueField: 'id_finalidad',
                displayField: 'nombre_finalidad',
                //tpl:'<tpl for="."><div class="x-combo-list-item"><p><b>{nro_cuenta}</b></p><p>{denominacion}</p></div></tpl>',
                hiddenName: 'id_finalidad',
                forceSelection:true,
                typeAhead: false,
                triggerAction: 'all',
                lazyRender:true,
                mode:'remote',
                pageSize:10,
                queryDelay:1000,
                listWidth:600,
                resizable:true,
                anchor:'80%',
                renderer : function(value, p, record) {
					//return String.format(record.data['nombre_finalidad']);
					return String.format('{0}', '<FONT COLOR="'+record.data['color']+'"><b>'+record.data['nombre_finalidad']+'</b></FONT>');
				}
            },
            type:'ComboBox',
            id_grupo:0,
            filters:{   
                        pfiltro:'nombre_finalidad',
                        type:'string'
                    },
            grid:true,
            form:true
        },
		{
			config: {
				name: 'id_libro_bancos_fk',
				fieldLabel: 'Deposito Asociado',
				allowBlank: true,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					url: '../../sis_/control/Clase/Metodo',
					id: 'id_',
					root: 'datos',
					sortInfo: {
						field: 'nombre',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_', 'nombre', 'codigo'],
					remoteSort: true,
					baseParams: {par_filtro: 'movtip.nombre#movtip.codigo'}
				}),
				valueField: 'id_',
				displayField: 'nombre',
				gdisplayField: 'desc_',
				hiddenName: 'id_libro_bancos_fk',
				forceSelection: true,
				typeAhead: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 15,
				queryDelay: 1000,
				anchor: '100%',
				gwidth: 150,
				minChars: 2,
				renderer : function(value, p, record) {
					return String.format('{0}', record.data['desc_']);
				}
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters: {pfiltro: 'movtip.nombre',type: 'string'},
			grid: false,
			form: true
		},
		{
            config:{
                name: 'num_tramite',
                fieldLabel: 'Num. Tramite',
                allowBlank: true,
                anchor: '80%',
                gwidth: 150,
                maxLength:200
            },
            type:'TextField',
            filters:{pfiltro:'lban.num_tramite',type:'string'},
            id_grupo:1,
            grid:true,
            form:false
        },		
		{
			config:{
				name: 'indice',
				fieldLabel: 'Indice',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:1310722
			},
				type:'NumberField',
				filters:{pfiltro:'lban.indice',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'estado_reg',
				fieldLabel: 'Estado Reg.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:10
			},
				type:'TextField',
				filters:{pfiltro:'lban.estado_reg',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},		
		{
			config:{
				name: 'fecha_reg',
				fieldLabel: 'Fecha creación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
							format: 'd/m/Y', 
							renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
				type:'DateField',
				filters:{pfiltro:'lban.fecha_reg',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'usr_reg',
				fieldLabel: 'Creado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'NumberField',
				filters:{pfiltro:'usr_reg',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'fecha_mod',
				fieldLabel: 'Fecha Modif.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
							format: 'd/m/Y', 
							renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
				type:'DateField',
				filters:{pfiltro:'lban.fecha_mod',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'usr_mod',
				fieldLabel: 'Modificado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'NumberField',
				filters:{pfiltro:'usu2.cuenta',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		}],
		title : 'Depositos',
		ActSave:'../../sis_migracion/control/TsLibroBancos/insertarTsLibroBancos',
	ActDel:'../../sis_migracion/control/TsLibroBancos/eliminarTsLibroBancos',
	ActList:'../../sis_migracion/control/TsLibroBancos/listarTsLibroBancos',
	id_store : 'id_libro_bancos',
		fields: [
		{name:'id_libro_bancos', type: 'numeric'},
		{name:'num_tramite', type: 'string'},
		{name:'id_cuenta_bancaria', type: 'numeric'},
		{name:'fecha', type: 'date',dateFormat:'Y-m-d'},
		{name:'id_proceso_wf', type: 'numeric'},
		{name:'id_estado_wf', type: 'numeric'},
		{name:'id_depto', type: 'numeric'},
		{name:'nombre', type: 'string'},
		{name:'a_favor', type: 'string'},
		{name:'nro_cheque', type: 'numeric'},
		{name:'importe_deposito', type: 'numeric'},
		{name:'nro_liquidacion', type: 'string'},
		{name:'detalle', type: 'string'},
		{name:'origen', type: 'string'},
		{name:'observaciones', type: 'string'},
		{name:'importe_cheque', type: 'numeric'},
		{name:'id_libro_bancos_fk', type: 'numeric'},
		{name:'estado', type: 'string'},
		{name:'nro_comprobante', type: 'string'},
		{name:'indice', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'tipo', type: 'string'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'id_depto', type: 'numeric'},
		{name:'nombre', type: 'string'},
		{name:'id_finalidad', type: 'numeric'},
		{name:'nombre_finalidad', type: 'string'},
		{name:'color', type: 'string'},
		{name:'saldo_deposito', type: 'numeric'}
	],
		sortInfo : {
			field : 'id_libro_bancos',
			direction : 'DESC'
		},
		bdel : true,
		bsave : false,
		fheight:'80%',
		
		iniciarEventos:function(){
		
			this.cmpTipo = this.getComponente('tipo');		
			this.cmpNroCheque = this.getComponente('nro_cheque');
			this.cmpImporteCheque = this.getComponente('importe_cheque');
			this.cmpImporteDeposito = this.getComponente('importe_deposito');
			this.cmpIdLibroBancosFk = this.getComponente('id_libro_bancos_fk');
			this.cmpDepto = this.getComponente('id_depto');
			this.cmpFecha = this.getComponente('fecha');
			
			this.ocultarComponente(this.cmpNroCheque);
			this.ocultarComponente(this.cmpImporteCheque);
			this.ocultarComponente(this.cmpIdLibroBancosFk);
			this.cmpTipo.disable();
		},
				
		preparaMenu:function(n){
			  var data = this.getSelectedData();
			  
			  Phx.vista.TsLibroBancosDeposito.superclass.preparaMenu.call(this,n); 
			  if(data['id_proceso_wf'] !== null){
				  if (data['estado']== 'borrador'){
					  this.getBoton('edit').enable();				  
					  this.getBoton('del').enable();    
					  this.getBoton('fin_registro').enable();				 
					  this.getBoton('btnReporteDeposito').enable();	  
				  }
				  else{				  
					  
					   if (data['estado'] == 'depositado'){   
						  this.getBoton('fin_registro').disable();
						  this.getBoton('btnReporteDeposito').enable();
						}					
						else{
						  this.getBoton('fin_registro').enable();
						  this.getBoton('btnReporteDeposito').disable();
						}
						this.getBoton('edit').enable();
						this.getBoton('del').disable();
				   }
			  }
			  else{
			    //this.menuAdq.disable();				  
			    this.getBoton('fin_registro').disable();
				this.getBoton('edit').disable();
				this.getBoton('del').disable();
			  }	
		 },
		 
		 sigEstado:function(){                   
		  var rec=this.sm.getSelected();
		  this.objWizard = Phx.CP.loadWindows('../../../sis_workflow/vista/estado_wf/FormEstadoWf.php',
									'Estado de Wf',
									{
										modal:true,
										width:700,
										height:450
									}, {data:{
										   id_estado_wf:rec.data.id_estado_wf,
										   id_proceso_wf:rec.data.id_proceso_wf,
										   fecha_ini:rec.data.fecha_tentativa
										  
										}}, this.idContenedor,'FormEstadoWf',
									{
										config:[{
												  event:'beforesave',
												  delegate: this.onSaveWizard												  
												}],
										
										scope:this
									 });        
				   
		 },	   
		
		onSaveWizard:function(wizard,resp){
			Phx.CP.loadingShow();
			console.log(resp);
			Ext.Ajax.request({
				url:'../../sis_migracion/control/TsLibroBancos/siguienteEstadoLibroBancos',
				params:{
						
					id_proceso_wf_act:  resp.id_proceso_wf_act,
					id_estado_wf_act:   resp.id_estado_wf_act,
					id_tipo_estado:     resp.id_tipo_estado,
					id_funcionario_wf:  resp.id_funcionario_wf,
					id_depto_wf:        resp.id_depto_wf,
					obs:                resp.obs,
					json_procesos:      Ext.util.JSON.encode(resp.procesos)
					},
				success:this.successWizard,
				failure: this.conexionFailure,
				argument:{wizard:wizard},
				timeout:this.timeout,
				scope:this
			});
		},
		
		successWizard:function(resp){
			Phx.CP.loadingHide();
			resp.argument.wizard.panel.destroy()
			this.reload();
		 },
		 
		clonar:function(){
			var data = this.getSelectedData();
			this.onButtonNew();
			
			this.cmpAFavor = this.getComponente('a_favor');
			this.cmpObservaciones = this.getComponente('observaciones');
			this.cmpDetalle = this.getComponente('detalle');		
			this.cmpNroLiquidacion = this.getComponente('nro_liquidacion');
			this.cmpIdLibroBancosFk = this.getComponente('id_libro_bancos_fk');
			
			this.cmpTipo.setValue(data.tipo);
			this.cmpAFavor.setValue(data.a_favor);
			this.cmpObservaciones.setValue(data.observaciones);
			this.cmpDetalle.setValue(data.detalle);
			this.cmpNroLiquidacion.setValue(data.nro_liquidacion);
			this.cmpIdLibroBancosFk.setValue(data.id_libro_bancos_fk);
			
		},
		
		onButtonEdit:function(){
			Phx.vista.TsLibroBancosDeposito.superclass.onButtonEdit.call(this);
			var data = this.getSelectedData();
			
			if(data.estado=='depositado'){
				this.cmpDepto.disable();
				this.cmpFecha.disable();
				this.cmpImporteDeposito.disable();
			}else{
				this.cmpDepto.enable();
				this.cmpFecha.enable();
				this.cmpImporteDeposito.enable();
			}
		},
		
		reporteDeposito : function(){
			var data = this.getSelectedData();
			var NumSelect=this.sm.getCount();
			
			if(NumSelect != 0)
			{		
				var data='idLibroBancos='+ data.id_libro_bancos;  			
				//window.open('http://172.17.45.11/ReportesEndeSis/Home/MemorandumFondosEnAvance?'+data);
				window.open('http://sms.obairlines.bo/LibroBancos/Home/VerLibroBancosDeposito?'+data);
			}
			else
			{
				Ext.MessageBox.alert('Alerta', 'Antes debe seleccionar un item.');
			}
		},

		tabsouth:[{
			url : '../../../sis_migracion/vista/ts_libro_bancos_cheques/TsLibroBancosCheque.php',
			title : 'Cheques',
			height: '50%',
			cls : 'TsLibroBancosCheque'
		}, {
			url : '../../../sis_migracion/vista/ts_libro_bancos_depositos_extra/TsLibroBancosDepositoExtra.php',
			title : 'Depositos Extra',
			height: '50%',
			cls : 'TsLibroBancosDepositoExtra'
		}]
	}); 
</script>