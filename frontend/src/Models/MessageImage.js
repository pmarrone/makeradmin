import React from 'react';
import Base from './Base';


export default class MessageImage extends Base {

    deleteConfirmMessage() {
        return `Are you sure you want to delete image ${this.name_id}?`;
    }

    canSave() {
        return this.isDirty() && this.name_id;
    }
}

MessageImage.model = {
    id: "image_id",
    root: "/messages/image",
    attributes: {
        entity_id: 0,
        image_id: 0,
        name_id: "",
        title: "",
        attribution: "",
        description: "",
        mime: "",
        width: "",
        height: "",
        imagedata: "",
        created_at: null,
    },
};