<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SetForwarders.aspx.cs" Inherits="TCT.SetForwarders" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <asp:TextBox ID="NewForwarderNameTextBox" runat="server" Width="200" CssClass="grey"/>
    <asp:RequiredFieldValidator ID="ReqFieldValidatorNewForwarderName" runat="server" ErrorMessage="* Required field"
        ControlToValidate="NewForwarderNameTextBox" ValidationGroup="InsertNewForwarder" CssClass="red" Display="Dynamic" />
    <asp:Button ID="NewForwarderButton" runat="server" CausesValidation="true" ValidationGroup="InsertNewForwarder"
        Text="Create New Forwarder" OnClick="NewForwarderButton_Click"/>
        
    <asp:GridView ID="GridViewForwarder" runat="server" AutoGenerateColumns="false" CellPadding="4" ForeColor="#333333" GridLines="None" 
        DataKeyNames="ForwarderID" DataSourceID="SqlDataSource_Forwarder" EnablePersistedSelection="true" OnRowDataBound="GridViewForwarder_RowDataBound" >
        <AlternatingRowStyle BackColor="White" />
        <Columns>
            <asp:CommandField ButtonType="Button" ShowEditButton="true" />
            <asp:BoundField DataField="Name" HeaderText="Forwarder"/>
            <asp:BoundField DataField="Usage" HeaderText="Usage" ReadOnly="true"/>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:LinkButton ID="DeleteForwarderButton" runat="server" CommandName="delete" Text="X"
                        ControlStyle-ForeColor="Red" ControlStyle-Font-Bold="true" ControlStyle-Font-Underline="false"
                        OnClientClick="if (!window.confirm('Delete this Forwarder?')) return false;" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <FooterStyle BackColor="#507CD1" Font-Bold="true" ForeColor="White" />
        <HeaderStyle BackColor="#507CD1" Font-Bold="true" ForeColor="White" />
        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
        <RowStyle BackColor="#EFF3FB" />
        <EditRowStyle BackColor="#D1DDF1" Font-Bold="true" ForeColor="#333333" />
    </asp:GridView>

    <asp:SqlDataSource ID="SqlDataSource_Forwarder" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT f.ForwarderID, f.Name, count(d.DeliveryID) Usage 
            FROM Delivery.Forwarder f LEFT JOIN Delivery.DeliveryHeader d ON f.ForwarderID = d.ForwarderID
            GROUP BY f.ForwarderID, f.Name ORDER BY f.Name" 
        InsertCommand="INSERT INTO Delivery.Forwarder (Name) VALUES (@Name)" 
        UpdateCommand="UPDATE Delivery.Forwarder SET Name = @Name WHERE ForwarderID = @ForwarderID"
        DeleteCommand="DELETE FROM Delivery.Forwarder WHERE ForwarderID = @ForwarderID">
        <InsertParameters>
            <asp:ControlParameter Name="Name" ControlID="NewForwarderNameTextBox" PropertyName="Text" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="Name" />
            <asp:Parameter Name="ForwarderID" />
        </UpdateParameters>
        <DeleteParameters>
            <asp:Parameter Name="ForwarderID" />
        </DeleteParameters>
    </asp:SqlDataSource>

</asp:Content>
