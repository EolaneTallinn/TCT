<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" EnableViewState="false" CodeBehind="RepShippingDocs.aspx.cs" Inherits="TCT.RepShippingDocs" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    Timeframe:
    <asp:DropDownList ID="CreateDateDropDownList" runat="server" AutoPostBack="true">
        <asp:ListItem Value="30" Text="Last 30 days" />
        <asp:ListItem Value="183" Text="Last 6 months" />
        <asp:ListItem Value="365" Text="Last 12 months" />
        <asp:ListItem Value="1825" Text="Last 5 years" />
    </asp:DropDownList>

    <br />
    <br />
    <asp:GridView ID="GridViewReport_1" runat="server" CellPadding="3" GridLines="Vertical" AutoGenerateColumns="False"
        DataSourceID="SqlDataSource_Report_1" DataKeyNames="DocumentHeaderID" AllowPaging="True" PageSize="1000" AllowSorting="True">
        <Columns>
            <asp:BoundField DataField="DocumentHeaderID"  HeaderText="Doc Nr." SortExpression="DocumentHeaderID" />
            <asp:BoundField DataField="Status"            HeaderText="Status"  SortExpression="Status" />
            <asp:BoundField DataField="DocumentType"      HeaderText="Type"    SortExpression="DocumentType" />
            <asp:BoundField DataField="LinesCount"        HeaderText="Lines"   SortExpression="LinesCount" />
            <asp:BoundField DataField="Customer"          HeaderText="Customer" SortExpression="Customer" />
            <asp:BoundField DataField="DeclarationNumber" HeaderText="Declaration Number" SortExpression="DeclarationNumber" />
            <asp:BoundField DataField="DeclarationDate"   HeaderText="Declaration Date"  SortExpression="DeclarationDate" DataFormatString="{0:dd.MM.yyyy}" />
            <asp:BoundField DataField="CustomsCode"       HeaderText="Customs Code" SortExpression="CustomsCode" />
            <asp:BoundField DataField="TotalNetWeight"    HeaderText="NetWeight" SortExpression="TotalNetWeight" />
            <asp:BoundField DataField="TotalCost"         HeaderText="Cost"   SortExpression="TotalCost" DataFormatString="{0:F2}" ItemStyle-HorizontalAlign="Right" />
            <asp:BoundField DataField="Currency"          HeaderText="Currency" SortExpression="Currency" />
        </Columns>
        <FooterStyle BackColor="#507CD1" ForeColor="White" Font-Bold="True" />
        <HeaderStyle BackColor="#507CD1" ForeColor="White" Font-Bold="True" />
        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
        <AlternatingRowStyle BackColor="#DDEEFF" />
        <SortedAscendingCellStyle BackColor="#F5F7FB" />
        <SortedAscendingHeaderStyle BackColor="#6D95E1" />
        <SortedDescendingCellStyle BackColor="#E9EBEF" />
        <SortedDescendingHeaderStyle BackColor="#4870BE" />
        <EmptyDataTemplate><span class="red">No documents found during the <%= CreateDateDropDownList.SelectedItem %></span></EmptyDataTemplate>
    </asp:GridView>

    <asp:SqlDataSource ID="SqlDataSource_Report_1" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT h.DocumentHeaderID
                ,CASE h.Status WHEN 0 THEN 'Open' WHEN 1 THEN 'Processed' WHEN 2 THEN 'Closed' END as Status
                ,CASE h.DocumentType WHEN 1 THEN 'Products' WHEN 2 THEN 'Components' END as DocumentType
                ,COUNT(l.DocumentLineID) AS LinesCount 
                ,h.Customer
                ,h.DeclarationNumber
                ,DeclarationDate
                ,h.CustomsCode
                ,h.TotalNetWeight
                ,h.TotalCost
                ,h.Currency
            FROM Shipping.DocumentHeader h
            INNER JOIN Shipping.DocumentLine l ON h.DocumentHeaderID = l.DocumentHeaderID 
            WHERE h.CreateDate &gt; GETDATE()-CAST(@CreateDateDiff as int)
            GROUP BY h.DocumentHeaderID, h.Customer, h.DeclarationNumber, h.DeclarationDate, h.CustomsCode, h.TotalNetWeight, h.TotalCost, h.Currency, h.Status, h.DocumentType">
        <SelectParameters>
            <asp:ControlParameter Name="CreateDateDiff" ControlID="CreateDateDropDownList" PropertyName="SelectedValue" />
        </SelectParameters>
    </asp:SqlDataSource>

</asp:Content>
