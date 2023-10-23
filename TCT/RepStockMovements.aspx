<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" EnableViewState="false" CodeBehind="RepStockMovements.aspx.cs" Inherits="TCT.RepStockMovements" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/jscript" language="javascript">
        function collapseExpand(objID, imageID) {
            var gvObject = document.getElementById(objID);
            var imageID = document.getElementById(imageID);
 
            if (gvObject.style.display == 'none') {
                gvObject.style.display = 'inline';
                imageID.src = 'Images/minus.gif';
            } else {
                gvObject.style.display = 'none';
                imageID.src = 'Images/plus.gif';
            }
        }
        function collapseExpandAll(imageID) {
            objIDsArray = LineIDs; // "LineIDs" array is created by _RowDataBound function in C# code behind
            ExpandAllBtn = document.getElementById(imageID);
            var iLen = ExpandAllBtn.src.length;
            if (ExpandAllBtn.src.substring(iLen, iLen - 15) == 'Images/plus.gif') {
                ExpandAllBtn.src = 'Images/minus.gif';
                for (var i = 0; i < objIDsArray.length; i++) {
                    document.getElementById(objIDsArray[i]).style.display = 'inline';
                    document.getElementById('image' + objIDsArray[i]).src = 'Images/minus.gif';
                }
            } else {
                ExpandAllBtn.src = 'Images/plus.gif';
                for (var i = 0; i < objIDsArray.length; i++) {
                    document.getElementById(objIDsArray[i]).style.display = 'none';
                    document.getElementById('image' + objIDsArray[i]).src = 'Images/plus.gif';
                } 
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    Item:
    <asp:DropDownList ID="RepShippingDocsItemIDDropDownList" runat="server" AutoPostBack="true"
        DataSourceID="SqlDataSource_Stock" DataTextField="ItemID" DataValueField="ItemID" AppendDataBoundItems="True">
        <asp:ListItem></asp:ListItem>
    </asp:DropDownList>
    <asp:SqlDataSource ID="SqlDataSource_Stock" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT DISTINCT ItemID FROM Customs.Stock ORDER BY ItemID">
        <%--SELECT ItemID, ItemID + ' (qty:' + CAST(SUM(ActualQuantity) as varchar) + ')' Item FROM Customs.Stock GROUP BY ItemID--%>
    </asp:SqlDataSource>
    &nbsp;&nbsp;

    Import Declaration:
    <asp:DropDownList ID="RepShippingDocsDeclarationNumberDropDownList" runat="server" AutoPostBack="true"
        DataSourceID="SqlDataSource_DeclarationNumbers" DataTextField="DeclarationNumber" DataValueField="DeclarationNumber" AppendDataBoundItems="True">
        <asp:ListItem></asp:ListItem>
    </asp:DropDownList>
    <%-- Note! DeclarationDate is only a date (always 0:0:0 time), so we could also build a "Date-Picker" if better search capabilities are needed --%>
    <asp:SqlDataSource ID="SqlDataSource_DeclarationNumbers" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT DISTINCT DeclarationNumber FROM PurchaseOrder.PurchaseOrder ORDER BY DeclarationNumber">
    </asp:SqlDataSource>
    &nbsp;&nbsp;
     
    <br />
    <br />
    <asp:GridView ID="GridViewReport_4" runat="server" CellPadding="2" GridLines="Vertical" AutoGenerateColumns="False"
        DataSourceID="SqlDataSource_Report_4" DataKeyNames="StockID" AllowPaging="True" PageSize="1000" AllowSorting="True"
        OnRowDataBound="GridViewReport_4_RowDataBound">
        <Columns>
            <asp:TemplateField>
                <HeaderTemplate>
                    <a href="javascript:collapseExpandAll('imageLineID');">
                        <img id="imageLineID" alt="Show/Hide all" src="Images/plus.gif" />
                    </a>
                </HeaderTemplate>
                <ItemTemplate>
                    <span style="color:Gray"><%# Eval("InnerCount") %></span>
                    <a href="javascript:collapseExpand('LineID-<%# Eval("StockID") %>', 'imageLineID-<%# Eval("StockID") %>');">
                        <img id="imageLineID-<%# Eval("StockID") %>" alt="Show/Hide details" src="Images/plus.gif" style="vertical-align:middle"/>
                    </a>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="ItemID"            HeaderText="Item"          SortExpression="Item" />
            <asp:BoundField DataField="Description"       HeaderText="Description"   SortExpression="Description" />
            <asp:BoundField DataField="CustomsCode"       HeaderText="Customs Code"  SortExpression="CustomsCode" />
            <asp:BoundField DataField="DeclarationNumber" HeaderText="Import Decl"   SortExpression="DeclarationNumber" />
            <asp:BoundField DataField="DeclarationDate"   HeaderText="Date"          SortExpression="DeclarationDate" DataFormatString="{0:dd.MM.yyyy}" />
            <asp:BoundField DataField="CountryOfOrigin"   HeaderText="Origin"        SortExpression="CountryOfOrigin" />
            <asp:BoundField DataField="UnitPriceInLC"     HeaderText="Unit Price"    SortExpression="UnitPriceInLC" />
            <asp:BoundField DataField="LocalCurrency"     HeaderText="Currency"      SortExpression="LocalCurrency" />
            <asp:BoundField DataField="OriginalQuantity"  HeaderText="Original Qty"  SortExpression="OriginalQuantity" />
            <asp:BoundField DataField="ActualQuantity"    HeaderText="Current Stock" SortExpression="ActualQuantity" />
            <asp:TemplateField>
                <ItemTemplate>
                    </td></tr>
                    <tr><td colspan="100%"><div id="LineID-<%# Eval("StockID") %>" style="display:none;position:relative;left:25px;">
                        <asp:GridView ID="GridViewReport_Inner" runat="server" GridLines="Vertical" AutoGenerateColumns="False" 
                            EmptyDataText="No withdrawals have been made for this stock">
                            <Columns>
                                <asp:BoundField DataField="DeclarationNumber" HeaderText="Declaration" />
                                <asp:BoundField DataField="DeclarationDate"   HeaderText="Decl.Date" DataFormatString="{0:dd.MM.yyyy}"/>
                                <asp:BoundField DataField="DocumentHeaderID"  HeaderText="Proforma" ItemStyle-HorizontalAlign="Center"/>
                                <asp:BoundField DataField="MasterItemID"      HeaderText="Master Product" />
                                <asp:BoundField DataField="CustomsCode"       HeaderText="Customs Code" />
                                <asp:BoundField DataField="AllocatedQuantity" HeaderText="Shipped" />
                                <asp:BoundField DataField="LeftQuantity"      HeaderText="Balance" />
                            </Columns>
                            <HeaderStyle BackColor="#507CD1" ForeColor="White" Font-Bold="True" />
                        </asp:GridView>
                        <asp:SqlDataSource ID="SqlDataSource_Report_Inner" runat="server" 
                            ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                            SelectCommand="SELECT dh.DeclarationNumber
                                    ,dh.DeclarationDate
                                    ,dh.DocumentHeaderID
                                    ,CASE dh.DocumentType WHEN 1 THEN dl.ItemID WHEN 2 THEN '-' END as MasterItemID
                                    ,dl.CustomsCode
                                    ,dms.AllocatedQuantity 
                                    ,dms.LeftQuantity 
                                FROM Shipping.DocumentMaterial_Stock dms
                                INNER JOIN Shipping.DocumentMaterial dm ON dms.DocumentMaterialID = dm.DocumentMaterialID
                                INNER JOIN Shipping.DocumentLine     dl ON dm.DocumentLineID = dl.DocumentLineID
                                INNER JOIN Shipping.DocumentHeader   dh ON dl.DocumentHeaderID = dh.DocumentHeaderID
                                WHERE dms.StockID = @LineID
                                ORDER BY dms.LeftQuantity DESC">
                            <SelectParameters>
                                <asp:Parameter Name="LineID" />
                            </SelectParameters>
                        </asp:SqlDataSource>
                    </div></td></tr>
                    <tr><td colspan="100%">
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <FooterStyle BackColor="#507CD1" ForeColor="White" Font-Bold="True" />
        <HeaderStyle BackColor="#507CD1" ForeColor="White" Font-Bold="True" />
        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
        <AlternatingRowStyle BackColor="#DDEEFF" />
        <SortedAscendingCellStyle BackColor="#F5F7FB" />
        <SortedAscendingHeaderStyle BackColor="#6D95E1" />
        <SortedDescendingCellStyle BackColor="#E9EBEF" />
        <SortedDescendingHeaderStyle BackColor="#4870BE" />
    </asp:GridView>

    <asp:SqlDataSource ID="SqlDataSource_Report_4" runat="server" CancelSelectOnNullParameter="false"
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT s.StockID
                ,s.ItemID 
                ,po.[Description]
                ,po.CustomsCode 
                ,po.DeclarationNumber
                ,po.DeclarationDate
                ,po.CountryOfOrigin
                ,po.UnitPriceInLC 
                ,po.LocalCurrency 
                ,s.OriginalQuantity 
                ,s.ActualQuantity 
                ,count(dms.StockID) InnerCount
            FROM Customs.Stock s
            INNER JOIN PurchaseOrder.PurchaseOrder po ON s.PurchaseOrderLineID = po.PurchaseOrderLineID
            LEFT JOIN Shipping.DocumentMaterial_Stock dms ON s.StockID = dms.StockID
            WHERE   ((@ItemID IS     NULL AND @DeclarationNumber IS NOT NULL) OR s.ItemID = @ItemID)
                AND ((@ItemID IS NOT NULL AND @DeclarationNumber IS     NULL) OR po.DeclarationNumber = @DeclarationNumber)
            GROUP BY s.StockID, s.ItemID, po.Description, po.CustomsCode, po.DeclarationNumber, po.DeclarationDate, po.CountryOfOrigin, po.UnitPriceInLC, po.LocalCurrency, s.OriginalQuantity, s.ActualQuantity
            ORDER BY s.StockID">
        <SelectParameters>
            <asp:ControlParameter Name="ItemID" ControlID="RepShippingDocsItemIDDropDownList" PropertyName="SelectedValue" />
            <asp:ControlParameter Name="DeclarationNumber" ControlID="RepShippingDocsDeclarationNumberDropDownList" PropertyName="SelectedValue" />
        </SelectParameters>
    </asp:SqlDataSource>

</asp:Content>
