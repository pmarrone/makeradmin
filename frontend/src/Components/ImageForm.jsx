import React from 'react';
import TextInput from "./TextInput";
import {withRouter} from "react-router";
import Textarea from "./Textarea";
import DateTimeInput from "../Components/DateTimeInput";


class ImageForm extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            saveDisabled: true,
        };
    }

    componentDidMount() {
        const {image} = this.props;
        this.unsubscribe = image.subscribe(() => this.setState({saveDisabled: !image.canSave()}));
    }

    componentWillUnmount() {
        this.unsubscribe();
    }

    uploadComplete(filename) {
        return;
    }

    render() {
        const {image, onSave, onDelete} = this.props;
        const {saveDisabled} = this.state;

        return (
            <div className="meep">
                <form className="uk-form uk-margin-bottom" onSubmit={(e) => {e.preventDefault(); onSave(); return false;}}>
                    <div className="uk-form-row">
                        <img src={"data:"+ image.mime+";base64,"+image.imagedata}/>
                    </div>
                    <fieldset data-uk-margin>
                         <legend><i className="uk-icon-tag"/>Identifikation</legend>
                        <TextInput model={image} name="name_id" title="Unikt id" />
                        <TextInput model={image} name="title" title="Titel" />
                        <TextInput model={image} name="attribution" title="Erkännande" />
                        <Textarea model={image} name="description" title="Beskrivning" />
                    </fieldset>

                    <fieldset data-uk-margin>
                         <legend><i className="uk-icon-tag"/> Metadata</legend>
                         <TextInput model={image} name="mime" title="MIME" disabled={true}/>
                         <div className="uk-grid">
                            <div className="uk-width-1-2">
                                <TextInput model={image} name="width" title="Bredd" disabled={true}/>
                            </div>
                            <div className="uk-width-1-2">
                                <TextInput model={image} name="height" title="Höjd" disabled={true}/>
                            </div>
                            <div className="uk-width-1-2">
                                <DateTimeInput model={image} name="created_at" title="Skapad" disabled={true} />
                            </div>
                            <div className="uk-width-1-2">
                                <DateTimeInput model={image} name="updated_at" title="Ändrad" disabled={true} />
                            </div>
                        </div>
                    </fieldset>
                    <div className="uk-form-row uk-margin-top">
                        <div className="uk-form-controls">
                            {image.id ? <a className="uk-button uk-button-danger uk-float-left" onClick={onDelete}><i className="uk-icon-trash"/> Ta bort bild</a> : ""}
                            <button className="uk-button uk-button-success uk-float-right" disabled={saveDisabled}><i className="uk-icon-save"/> {image.id ? 'Spara' : 'Skapa'}</button>
                        </div>
                    </div>
                </form>
            </div>
        );
    }
}


export default withRouter(ImageForm);