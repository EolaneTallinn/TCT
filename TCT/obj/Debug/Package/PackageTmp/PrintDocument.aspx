<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PrintDocument.aspx.cs" Inherits="TCT.PrintDocument" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        body {
            font-family: Verdana;
            font-size: 14px;
            border-collapse: collapse;
        }
        .nextpage {
            page-break-before: always;
        }
        .tblwidth {
            width: 700px;
        }
        .pucc_title {
            font-size: 16px;
            font-weight: bold;
        }
        .small {
            font-size: 10px;
        }
        .line {
            border-bottom: 1px solid black;
        }
        .line2 {
            border-bottom: 3px double black;
        }
        .footer {
            font-size: 10px;
            position:fixed;
            width:700px;
            height:70px;
            padding:5px;
            bottom:0px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        
        <asp:FormView ID="FormViewDocumentHeader" runat="server" DataSourceID="SqlDataSource_DocumentHeader" DataKeyNames="DocumentHeaderID" OnDataBound="FormViewDocumentHeader_DataBound">
            <ItemTemplate>
                <table class="tblwidth">
                    <tr>
                        <td rowspan="2" style="width: 500px;">
                            <img src="Images/logo-eolane2.gif" alt=""/><br />
                            EOLANE Tallinn AS
                        </td>
                        <td colspan="2">
                            Proforma Invoice
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 100px;">
                            <span class="small">No:</span><br />
                            <asp:Label ID="DocumentHeaderIDLabel" runat="server" Text='<%# Eval("DocumentHeaderID") %>' />
                        </td>
                        <td style="width: 100px;">
                            <span class="small">Date:</span><br />
                            <asp:Label ID="CreateDateLabel" runat="server" Text='<%# Eval("CreateDate") %>' />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" class="line">
                        </td>
                    </tr>
                    <tr>
                        <td class="line">
                            <span class="small">Customer:</span><br />
                            EOLANE TALLINN AS<br />
                            <br />
                            Peterburi tee 66<br />
                            Tallinn<br />
                            EESTI
                        </td>
                        <td colspan="2" class="line">
                            <span class="small">Country of origin:</span><br />
                            -
                            <br />
                            <span class="small"><br />Tariff code:</span><br />
                            <asp:Label ID="CustomsCodeLabel" runat="server" Text='<%# Eval("CustomsCode") %>' />
                            <br />
                            <span class="small"><br />Total Cost (based on StdUnitCost):</span><br />
                            <asp:Label ID="Label1" runat="server" Text='<%# Eval("TotalCost") %>' /> EUR
                        </td>
                    </tr>
                    <tr>
                        <td class="line2">
                            <span class="small">Description of goods:</span><br />
                            -
                        </td>
                        <td class="line2">
                            <span class="small">Net wt. kg:</span><br />
                            <asp:Label ID="TotalNetWeightLabel" runat="server" Text='<%# Eval("TotalNetWeightInKg") %>' />
                        </td>
                        <td class="line2">
                            <span class="small"><%--Gr. wt. kg:--%></span><br />
                            
                        </td>
                    </tr>
                </table>
            </ItemTemplate>
        </asp:FormView>

        <asp:SqlDataSource ID="SqlDataSource_DocumentHeader" runat="server" 
            ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
            SelectCommand="SELECT DocumentHeaderID, CONVERT(varchar, CreateDate, 104) CreateDate, CustomsCode, TotalNetWeight/1000 TotalNetWeightInKg, ROUND(TotalCost,2) TotalCost, DocumentType
                FROM Shipping.DocumentHeader WHERE DocumentHeaderID=@DocumentHeaderID">
            <SelectParameters>
                <asp:Parameter Name="DocumentHeaderID" DefaultValue="0"/>
            </SelectParameters>
        </asp:SqlDataSource>

        <br /><br />

        <asp:GridView ID="GridViewDocumentLine" runat="server" width="700px" Visible="false"
            AutoGenerateColumns="False" DataKeyNames="DocumentLineID" DataSourceID="SqlDataSource_DocumentLine"
            CellPadding="4" ForeColor="black" GridLines="None" ShowFooter="True" OnRowDataBound="GridViewDocumentLine_RowDataBound">
            <Columns>
                <asp:BoundField DataField="ItemID" HeaderText="Product" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left"/>
                <asp:BoundField DataField="Description" HeaderText="Description" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left"/>
                <asp:TemplateField HeaderText="Quantity" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                    <ItemTemplate>
                        <asp:Label ID="QuantityLabel" runat="server" Text='<%# Math.Round(Convert.ToDecimal(Eval("Quantity")), 2) %>'/>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Label ID="QuantitySumLabel" runat="server" Font-Bold="true"/>
                    </FooterTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="StdUnitCost" HeaderText="Std Unit Cost" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right"/>
                <asp:TemplateField HeaderText="Total" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                    <ItemTemplate>
                        <asp:Label ID="TotalPriceLabel" runat="server" Text='<%# Math.Round(Convert.ToDecimal(Eval("TotalPrice")), 2) %>'/>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Label ID="TotalPriceSumLabel" runat="server" Font-Bold="true"/>
                    </FooterTemplate>
                </asp:TemplateField>
            </Columns>
            <HeaderStyle Font-Bold="True"/>
        </asp:GridView>

        <asp:SqlDataSource ID="SqlDataSource_DocumentLine" runat="server" 
            ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
            SelectCommand="SELECT DocumentLineID, Quantity, ItemID, Description, StdUnitCost, Quantity*StdUnitCost TotalPrice FROM Shipping.DocumentLine WHERE DocumentHeaderID=@DocumentHeaderID">
            <SelectParameters>
                <asp:Parameter Name="DocumentHeaderID" DefaultValue="0"/>
            </SelectParameters>
        </asp:SqlDataSource>

       
        <asp:Panel ID="PanelFooter" runat="server" CssClass="footer" Visible="false">
            <table style="width: 100%;">
                <tr>
                    <td style="vertical-align:top;">
                        <b>AS Eolane Tallinn</b><br />
                        Peterburi tee 66<br />
                        11415 TALLINN<br />
                        ESTONIA
                    </td>
                    <td style="vertical-align:top;">
                        <br />
                        Phone:<br />
                        Fax<br />
                    </td>
                    <td style="vertical-align:top;">
                        <br />
                        +372 684 9000<br />
                        +372 684 9001<br />
                    </td>
                    <td style="vertical-align:top;">
                        <b>Company registration number</b><br />
                        Bank accounts:<br />
                        Swedbank, Tallinn, Liivalaia
                    </td>
                    <td style="vertical-align:top;">
                        <b>10092440</b><br />
                        <br />
                        22-1001142843
                    </td>
                </tr>
            </table>
        </asp:Panel>

        <asp:Repeater ID="RepeaterDocumentMaterial" runat="server" DataSourceID="SqlDataSource_DocumentLine" 
            OnItemDataBound="RepeaterDocumentMaterial_ItemDataBound" Visible="false">
            <ItemTemplate>
                
                <asp:Panel ID="PuccMaterialsPanel" runat="server">
                <h3>MANUFACTURED PUCC MATERIALS</h3>

                <table class="tblwidth">
                    <tr>
                        <td>Product</td>
                        <td><%# Eval("ItemID") %></td>
                        <td>Proforma</td>
                        <td><%# DataBinder.Eval(FormViewDocumentHeader.DataItem, "DocumentHeaderID").ToString() %></td>
                    </tr>
                    <tr>
                        <td>Description</td>
                        <td><%# Eval("Description")%></td>
                        <td>Date</td>
                        <td><%# DataBinder.Eval(FormViewDocumentHeader.DataItem, "CreateDate").ToString() %></td>
                    </tr>
                    <tr>
                        <td>Quantity</td>
                        <td><%# Eval("Quantity")%></td>
                        <td>License</td>
                        <td>TLL</td>
                    </tr>
                </table>
                <br />

                <asp:GridView ID="GridViewDocumentMaterial" runat="server" AutoGenerateColumns="False" Width="700px" CssClass="small"
                    DataSourceID="SqlDataSource_DocumentMaterial" OnDataBound="GridViewDocumentMaterial_DataBound">
                    <Columns>
                        <asp:BoundField DataField="ItemID"       HeaderText="Item" />
                        <asp:BoundField DataField="Description"  HeaderText="Description" />
                        <asp:BoundField DataField="CustomsCode"  HeaderText="Customs Code" />
                        <asp:BoundField DataField="CountryOfOrigin" HeaderText="Origin" />
                        <asp:BoundField DataField="Declaration"      HeaderText="Import Declaration" />
                        <asp:BoundField DataField="AllocatedQuantity" HeaderText="Qty" />
                        <asp:BoundField DataField="Cost"          HeaderText="Value" DataFormatString="{0:F2}" />
                        <asp:BoundField DataField="LocalCurrency" HeaderText="Currency" />
                    </Columns>
                </asp:GridView>

                <asp:SqlDataSource ID="SqlDataSource_DocumentMaterial" runat="server" OnSelected="SqlDataSource_DocumentMaterial_Selected"
                    ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                    SelectCommand="SELECT Mat.ItemID, Mat.Description, PO.CustomsCode, PO.CountryOfOrigin, PO.DeclarationNumber + ' ' + CONVERT(varchar, PO.DeclarationDate, 104) Declaration, MatStock.AllocatedQuantity, MatStock.AllocatedQuantity*PO.UnitPriceInLC Cost, PO.LocalCurrency
                        FROM Shipping.DocumentMaterial Mat
                        INNER JOIN Shipping.DocumentMaterial_Stock MatStock ON Mat.DocumentMaterialID = MatStock.DocumentMaterialID
                        INNER JOIN Customs.Stock Stock ON MatStock.StockID = Stock.StockID
                        INNER JOIN PurchaseOrder.PurchaseOrder PO ON Stock.PurchaseOrderLineID = PO.PurchaseOrderLineID
                        WHERE DocumentLineID=@DocumentLineID">
                    <SelectParameters>
                        <asp:Parameter Name="DocumentLineID" />
                    </SelectParameters>
                </asp:SqlDataSource>

                <br /><br />
                </asp:Panel>

            </ItemTemplate>
        </asp:Repeater>



        <%-------------------------------------------------------------------------------%>
        <%-----------------------  DIRECT  COMPONENT  WITHDRAWAL  -----------------------%>
        <%-------------------------------------------------------------------------------%>

        <asp:GridView ID="GridViewDocumentLineForComponents" runat="server" width="700px" Visible="false"
            AutoGenerateColumns="False" DataKeyNames="StockID" DataSourceID="SqlDataSource_DocumentLineForComponents"
            CellPadding="2" ForeColor="Black" CssClass="small">
            <Columns>
                <asp:BoundField DataField="ItemID"               HeaderText="Item Code" />
                <asp:BoundField DataField="Description"          HeaderText="Description" />
                <asp:BoundField DataField="CountryOfOrigin"      HeaderText="Origin" />
                <asp:BoundField DataField="ImpDeclarationNumber" HeaderText="Import Decl." />
                <asp:BoundField DataField="ImpDeclarationDate"   HeaderText="Date" DataFormatString="{0:dd.MM.yyyy}" />
                <asp:BoundField DataField="ExpDeclarationNumber" HeaderText="Decl." />
                <asp:BoundField DataField="ExpDeclarationDate"   HeaderText="Date" DataFormatString="{0:dd.MM.yyyy}" />
                <asp:BoundField DataField="AllocatedQuantity"    HeaderText="Deducted Qty" ItemStyle-HorizontalAlign="Right" />
                <asp:BoundField DataField="Value"                HeaderText="Value" DataFormatString="{0:F2}" />
                <asp:BoundField DataField="LocalCurrency"        HeaderText="Currency" />
            </Columns>
            <HeaderStyle Font-Bold="True" />
        </asp:GridView>

        <asp:SqlDataSource ID="SqlDataSource_DocumentLineForComponents" runat="server" 
            ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
            SelectCommand="SELECT
                     s.StockID
                    ,PO.DeclarationNumber ImpDeclarationNumber
                    ,PO.DeclarationDate   ImpDeclarationDate
                    ,PO.CountryOfOrigin 
                    ,PO.ItemID 
                    ,PO.Description 
                    ,dh.DeclarationNumber ExpDeclarationNumber
                    ,dh.DeclarationDate   ExpDeclarationDate
                    ,dms.AllocatedQuantity
                    ,PO.UnitPriceInLC * dms.AllocatedQuantity Value
                    ,PO.LocalCurrency 
                FROM Customs.Stock s
                INNER JOIN PurchaseOrder.PurchaseOrder     po  ON s.PurchaseOrderLineID = po.PurchaseOrderLineID
                INNER JOIN Shipping.DocumentMaterial_Stock dms ON s.StockID = dms.StockID
                INNER JOIN Shipping.DocumentMaterial       dm  ON dms.DocumentMaterialID = dm.DocumentMaterialID
                INNER JOIN Shipping.DocumentLine           dl  ON dm.DocumentLineID = dl.DocumentLineID
                INNER JOIN Shipping.DocumentHeader         dh  ON dl.DocumentHeaderID = dh.DocumentHeaderID
                WHERE dh.DocumentHeaderID = @DocumentHeaderID
                ORDER BY s.StockID">
            <SelectParameters>
                <asp:Parameter Name="DocumentHeaderID" DefaultValue="0"/>
            </SelectParameters>
        </asp:SqlDataSource>

    </form>
</body>
</html>
