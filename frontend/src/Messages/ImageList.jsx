import React from 'react';
import Collection from "../Models/Collection";
import CollectionTable from "../Components/CollectionTable";
import MessageImage from "../Models/MessageImage";
import DateTimeShow from "../Components/DateTimeShow";
import {Link} from "react-router";
import ImageFileInput from "../Components/ImageFileInput";

const Row = props => {
    const {item, deleteItem} = props;

    return (
        <tr>
            <td><Link to={"/messages/images/" + item.image_id}>{item.image_id}</Link></td>
            <td><img src={"data:"+ item.mime+";base64,"+item.imagedata}/></td>
            <td><Link to={"/messages/images/" + item.image_id}>{item.name_id}</Link><br/><DateTimeShow date={item.created_at}/></td>
            <td>{item.title}</td>
            <td>{item.mime}</td>
            <td>{item.width}</td>
            <td>{item.height}</td>
            <td><a onClick={() => deleteItem(item)} className="removebutton"><i className="uk-icon-trash"/></a></td>
        </tr>
    );
};

class ImageList extends React.Component {

    constructor(props) {
        super(props);
        this.collection = new Collection({type: MessageImage});
    }

    render() {
        return (
            <div className="uk-margin-top">
                <h2>Bilder</h2>
                <div className="uk-margin-top uk-form uk-form-stacked">
                    <div className="meep">
                        <form className="uk-form uk-margin-bottom" onSubmit={(e) => {e.preventDefault(); return false;}}>
                            <ImageFileInput action="/messages/image" onFile={() => {this.collection.fetch();}}/>
                        </form>
                    </div>
                </div>
                <p>Lista över samtliga bilder för meddelanden.</p>
                <CollectionTable
                    rowComponent={Row}
                    collection={this.collection}
                    columns={[
                        {title: "Id", sort: "image_id"},
                        {title: "Image"},
                        {title: "Unikt id", sort: "name_id"},
                        {title: "Titel", sort: "title"},
                        {title: "MIME", sort: "mime"},
                        {title: "Bredd", sort: "width"},
                        {title: "Höjd", sort: "height"},
                        {title: ""},
                    ]}
                />
            </div>
        );
    }
}


export default ImageList;
