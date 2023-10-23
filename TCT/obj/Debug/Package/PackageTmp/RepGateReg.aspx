<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" EnableViewState="false" CodeBehind="RepGateReg.aspx.cs" Inherits="TCT.RepGateReg" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    Forwarder:
    <asp:DropDownList ID="ForwarderDropDownList" runat="server"
        DataSourceID="SqlDataSource_Forwarder" DataTextField="Name" DataValueField="ForwarderID" AppendDataBoundItems="True">
        <asp:ListItem></asp:ListItem>
    </asp:DropDownList>
    <asp:SqlDataSource ID="SqlDataSource_Forwarder" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT ForwarderID, Name FROM Delivery.Forwarder ORDER BY Name">
    </asp:SqlDataSource>
    &nbsp;&nbsp;

    Supplier:
    <asp:DropDownList ID="SupplierDropDownList" runat="server"
        DataSourceID="SqlDataSource_Supplier" DataTextField="Name" DataValueField="SupplierID" AppendDataBoundItems="True">
        <asp:ListItem></asp:ListItem>
    </asp:DropDownList>
    <asp:SqlDataSource ID="SqlDataSource_Supplier" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT SupplierID, Name FROM Delivery.Supplier ORDER BY Name">
    </asp:SqlDataSource>
    <br /><br />

    Freight Bill:
    <asp:TextBox ID="FBTextBox" runat="server" onchange="this.value=this.value.trim()" />
    &nbsp;&nbsp;

    Timeframe:
    <asp:DropDownList ID="CreateDateDropDownList" runat="server" AutoPostBack="true">
        <asp:ListItem Value="30" Text="Last 30 days" />
        <asp:ListItem Value="183" Text="Last 6 months" />
        <asp:ListItem Value="365" Text="Last 12 months" />
        <asp:ListItem Value="1825" Text="Last 5 years" />
    </asp:DropDownList>
    &nbsp;&nbsp;

    <asp:Button ID="ShowButton" runat="server" Text="Show Report" />

    <br />
    <br />
    <asp:GridView ID="GridViewReport_5" runat="server" CellPadding="2" GridLines="Vertical" AutoGenerateColumns="False"
        DataSourceID="SqlDataSource_Report_5" DataKeyNames="DeliveryLineID" AllowPaging="True" PageSize="1000" AllowSorting="True"
        OnRowDataBound="GridViewReport_5_RowDataBound">
        <EmptyDataTemplate>No Gate Registrations found with this filter</EmptyDataTemplate>
        <Columns>
            <asp:BoundField DataField="DeliveryID"        HeaderText="Gate Reg."      SortExpression="DeliveryID" />
            <asp:BoundField DataField="CreateDate"        HeaderText="Created"        SortExpression="CreateDate" DataFormatString="{0:dd.MM.yyyy}" />
            <asp:BoundField DataField="T1Number"          HeaderText="T1Number"       SortExpression="T1Number" />
            <asp:BoundField DataField="Forwarder"         HeaderText="Forwarder"      SortExpression="Forwarder" />
            <asp:BoundField DataField="Truck"             HeaderText="Truck"          SortExpression="Truck" />
            <asp:BoundField DataField="DeliveryLineID"    HeaderText="Line ID"        SortExpression="DeliveryLineID" />
            <asp:BoundField DataField="FreightBillNumber" HeaderText="Freight Bill"   SortExpression="FreightBillNumber" />
            <asp:BoundField DataField="Supplier"          HeaderText="Supplier"       SortExpression="Supplier" />
            <asp:BoundField DataField="CountryOfDispatch" HeaderText="Dispatch"       SortExpression="CountryOfDispatch" />
            <asp:BoundField DataField="Incoterm"          HeaderText="Incoterm"       SortExpression="Incoterm" />
            <asp:BoundField DataField="GrossWeight"       HeaderText="GrossWeight"    SortExpression="GrossWeight" />
            <asp:BoundField DataField="PackageCount"      HeaderText="PackageCount"   SortExpression="PackageCount" />
            <asp:BoundField DataField="Comment"           HeaderText="Comment"        SortExpression="Comment" />
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:Repeater ID="RepeaterReport_Inner" runat="server">
                        <ItemTemplate>
                            <a href="<%# Container.DataItem %>" target="_blank"><img src="Images/file-icon.jpg" alt="" /></a>
                            <%--  <%# System.IO.Path.GetFileName(Container.DataItem.ToString()) %>  --%>
                            <%--  Container.DataItem [2] ?!?     <asp:BoundField DataField="CreateDate" DataFormatString="{0:g}" ItemStyle-Font-Size="Smaller" />  --%>
                        </ItemTemplate>
                    </asp:Repeater>
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
    
    <asp:SqlDataSource ID="SqlDataSource_Report_5" runat="server" CancelSelectOnNullParameter="false" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT h.DeliveryID
                ,h.CreateDate
                ,h.T1Number
                ,f.Name [Forwarder]
                ,h.TruckRegistrationNumber [Truck]
                ,l.DeliveryLineID
                ,l.FreightBillNumber
                ,s.Name [Supplier]
                ,l.CountryOfDispatch
                ,l.Incoterm
                ,l.GrossWeight
                ,l.PackageCount
                ,l.Comment
                ,STUFF((
                        SELECT ',' + a.Path + a.FileName FROM Delivery.Attachment a
                        WHERE a.DeliveryLineID = l.DeliveryLineID FOR xml path('')
                    ),1,1,'') [Attachments]
            FROM Delivery.DeliveryHeader h
            INNER JOIN Delivery.DeliveryLine l ON h.DeliveryID = l.DeliveryID
            INNER JOIN Delivery.Forwarder f ON h.ForwarderID = f.ForwarderID
            INNER JOIN Delivery.Supplier s ON l.SupplierID = s.SupplierID
            WHERE   (@ForwarderID       IS NULL OR h.ForwarderID = @ForwarderID)
                AND (@SupplierID        IS NULL OR l.SupplierID  = @SupplierID)
                AND (@FreightBillNumber IS NULL OR l.FreightBillNumber LIKE '%' + @FreightBillNumber + '%')
                AND h.CreateDate &gt; GETDATE()-CAST(@CreateDateDiff as int)
            ORDER BY h.CreateDate DESC">
        <SelectParameters>
            <asp:ControlParameter Name="ForwarderID" ControlID="ForwarderDropDownList" PropertyName="SelectedValue" />
            <asp:ControlParameter Name="SupplierID" ControlID="SupplierDropDownList" PropertyName="SelectedValue" />
            <asp:ControlParameter Name="FreightBillNumber" ControlID="FBTextBox" PropertyName="Text" />
            <asp:ControlParameter Name="CreateDateDiff" ControlID="CreateDateDropDownList" PropertyName="SelectedValue" />
        </SelectParameters>
    </asp:SqlDataSource>

</asp:Content>
