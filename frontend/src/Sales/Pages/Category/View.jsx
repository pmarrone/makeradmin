import React from 'react'
import Backbone from 'backbone'

// Backbone
import OrderRowCollection from '../../Collections/OrderRow'
import OrderRows from '../../Components/Tables/OrderRows'
import OrderActions from '../../Components/Tables/OrderActions'
import OrderEvents from '../../Components/Tables/OrderEvents'
import OrderModel from '../../Models/Order'
import OrderActionModel from '../../Models/OrderAction'
import OrderEventModel from '../../Models/OrderEvent'

module.exports = React.createClass({
	getInitialState: function()
	{
		console.log(this.props.params);
		var order = new OrderModel({id: this.props.params.id});
		order.fetch();

		return {
			model: order,
		};
	},

	render: function()
	{
		return (
			<div>
				<h2>Order #{this.props.params.id}</h2>
				<div>Medlem:</div><br/>
				<div>Skapad:</div><br/>
				<OrderRows type={OrderRowCollection} dataSource={{
					url: "/webshop/transaction/" + this.props.params.id + "/content"
				}} />
				<h3>Ordereffekter</h3>
				<OrderActions type={Backbone.PageableCollection.extend({model: OrderActionModel})} dataSource={{
					url: "/webshop/transaction/" + this.props.params.id + "/actions"
				}} />
				<h3>Orderhändelser</h3>
				<OrderEvents type={Backbone.PageableCollection.extend({model: OrderEventModel})} dataSource={{
					url: "/webshop/transaction/" + this.props.params.id + "/events"
				}} />
			</div>
		);
	},
});