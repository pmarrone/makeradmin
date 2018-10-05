import React from 'react';

import ImageForm from '../Components/ImageForm';
import {browserHistory} from 'react-router';
import Image from "../Models/MessageImage";
import {confirmModal} from "../message";


class ImageEdit extends React.Component {

    constructor(props) {
        super(props);
        const {image_id} = props.params;
        this.image = Image.get(image_id);
        this.state = {saveDisabled: true};
    }

    componentDidMount() {
        this.unsubscribe = this.image.subscribe(() => this.setState({saveDisabled: !this.image.canSave()}));
    }

    componentWillUnmount() {
        this.unsubscribe();
    }

    render() {
        const onDelete = () => {
            return confirmModal(this.image.deleteConfirmMessage())
                .then(() => this.image.del())
                .then(() => browserHistory.replace('/messages/images'))
                .catch(() => null);
        };

        return (
           <div>
                <h2>Redigera bildegenskaper</h2>
                <ImageForm
                    image={this.image}
                    onSave={() => this.image.save().then(() => browserHistory.replace('/messages/images'))}
                    onDelete={onDelete}
                />
           </div>
        );
    }
}

export default ImageEdit;
