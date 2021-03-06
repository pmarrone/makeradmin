import * as common from "./common"
import Cart from "./cart"
import {UNAUTHORIZED} from "./common";
declare var UIkit: any;


common.onGetAndDocumentLoaded("/webshop/product_edit_data/" + window.productId, (value: any) => {
    common.addSidebarListeners();

    const {categories, product, actions, images, filters, action_categories} = value;
    const apiBasePath = window.apiBasePath;

    let categorySelect = document.getElementById("category");
    categories.forEach((category: any) => {
        const selected = product.category_id === category.id ? "selected" : "";
        categorySelect.innerHTML += `<option value="${category.id}" ${selected}>${category.name}</option>`;
    });

    let filterSelect = document.getElementById("filter");
    filters.forEach((filter: any) => {
        const selected = product.filter === filter ? "selected" : "";
        filterSelect.innerHTML += `<option value="${filter}" ${selected}>${filter}</option>`;
    });

    let actionSelect = document.getElementById("add-action-category");
    action_categories.forEach((action: any) => {
        actionSelect.innerHTML += `<option value="${action.id}">${action.name}</option>`;
    });

    document.getElementById("name").setAttribute("value", product.name);
    document.getElementById("unit").setAttribute("value", product.unit);
    document.getElementById("price").setAttribute("value", product.price);
    document.getElementById("description").innerText = product.description;
    document.getElementById("smallest_multiple").setAttribute("value", product.smallest_multiple);

    const updateUnit = () => {
        const unit = (<HTMLInputElement>document.querySelector("#unit")).value;
        document.querySelector("#price-unit").innerHTML = Cart.currency + "/" + unit;
        document.querySelector("#multiple-unit").innerHTML = unit;
    };


    document.querySelector("#unit").addEventListener("input", ev => updateUnit());
    updateUnit();

    let deletedActionIDs : (number|string)[] = [];
    let deletedImageIDs : (number|string)[] = [];

    function addAction(action: any) {
        let options = "";
        for (const cat of action_categories) {
            options += `<option value="${ cat.id }" ${ action.action_id == cat.id ? "selected" : "" }>${cat.name}</option>`;
        }


        const wrapper = document.createElement('div');
        wrapper.innerHTML =
            `<div data-id="${ action.id }" class="product-action uk-flex uk-margin">
                <select required class="uk-select uk-margin-right">
                    ${options}
                </select>
                <input required class="uk-input uk-margin-right" type="number" value="${ action.value }" />
                <button type="button" class="uk-button uk-button-danger uk-button-small" uk-icon="trash"></button>
            </div>`;
        const element = <HTMLElement>wrapper.firstChild;

        element.querySelector("button").addEventListener("click", ev => {
            ev.preventDefault();
            // Note that the ID may change from its original value.
            // In particular new actions start out with an id of 'new' which is later changed when the action is saved.
            deletedActionIDs.push(element.getAttribute("data-id"));
            element.remove();
        });

        document.querySelector("#action-list").appendChild(element);
    }

    for (const action of actions) {
        addAction(action);
    }

    let isSaving = false;

    document.querySelector("#product-cancel").addEventListener("click", ev => {
        ev.preventDefault();
        // Redirect the user back to the webshop
        window.location.href = "/shop#edit";
    });

    // Handle image uploads
    const imageList = document.getElementById('image-list');
    function addImage(src: any, name: string, id: (number|string)) {
        const wrapper = document.createElement('div');
        wrapper.innerHTML =
            `<div data-id="${ id }" data-name="${ name }" class="product-image uk-flex uk-margin">
                <img/>
                <button type="button" class="uk-button uk-button-danger uk-button-small" uk-icon="trash"></button>
            </div>`;
        const element = <HTMLElement>wrapper.firstChild;
        element.getElementsByTagName("img")[0].src = src;

        element.querySelector("button").addEventListener("click", ev => {
            ev.preventDefault();
            // Note that the ID may change from its original value.
            // In particular new actions start out with an id of 'new' which is later changed when the action is saved.
            deletedImageIDs.push(element.getAttribute("data-id"));
            element.remove();
        });
        imageList.appendChild(element);
    }

    for (const image of images) {
        addImage("/shop/static/product_images/" + image.path, image.path, image.id);
    }

    const imageInput = <HTMLInputElement>document.getElementById('image-input');
    imageInput.addEventListener("change", ev => {
        if (imageInput.files && imageInput.files[0]) {
            const file = imageInput.files[0];
            const maxSize = 2000000; // In bytes
            if (file.size > maxSize) {
                UIkit.modal.alert(`Cannot upload this image because it is too large (maximum allowed size is ${maxSize} bytes, but the image size was ${file.size} bytes)`);
            } else {
                const reader = new FileReader();

                reader.onload = (ev: any) => {
                    addImage(ev.target.result, file.name, "new");
                }

                reader.readAsDataURL(file);
            }
            imageInput.files = null;
        }
    });

    // Wow: So much code!
    // Should probably simplify this...
    document.querySelector(".product-edit-form").addEventListener("submit", ev => {
        ev.preventDefault();
        if (isSaving) return;

        const type = window.productId === 0 ? "POST" : "PUT";
        const url = apiBasePath + "/webshop/product" + (window.productId === 0 ? "" : "/" + window.productId);
        const spinner = document.querySelector(".progress-spinner");
        spinner.classList.add("progress-spinner-visible");

        common.ajax(type, url, {
            id: window.productId,
            name: common.getValue("#name"),
            category_id: common.getValue("#category"),
            description: common.getValue("#description"),
            price: common.getValue("#price"),
            unit: common.getValue("#unit"),
            smallest_multiple: common.getValue("#smallest_multiple"),
            filter: common.getValue("#filter"),
        }).then(json => {
            if (window.productId === 0) {
                // Update the form with the created product id
                window.productId = json.data.id;
                history.replaceState(history.state, "Edit Product", window.productId + "/edit");
            }

            const futures : Promise<any>[] = [];
            [].forEach.call(document.querySelectorAll(".product-action"), (element: HTMLElement) => {
                const id2 = element.getAttribute("data-id");
                const value = element.querySelector("input").value;
                const actionID = element.querySelector("select").value;

                const type2 = id2 == "new" ? "POST" : "PUT";
                const url2 = apiBasePath + "/webshop/product_action" + (id2 == "new" ? "" : "/" + id2);
                const future = common.ajax(type2, url2, {
                    id: id2,
                    product_id: window.productId,
                    action_id: actionID,
                    value: value
                });
                futures.push(future);

                future.then(json => {
                    if (id2 == "new") {
                        // Update the form with the action id
                        element.setAttribute("data-id", json.data.id);
                    }
                    // UIkit.modal.alert("Saved action");
                }).catch (json => {
                    if (json.status === UNAUTHORIZED) {
                        UIkit.modal.alert("<h2>Failed to save action</h2>You are not logged in");
                    } else {
                        UIkit.modal.alert("<h2>Failed to save action</h2>" + common.get_error(json));
                    }
                });
            });

            for (const id2 of deletedActionIDs) {
                if (id2 !== "new") {
                    const url2 = apiBasePath + "/webshop/product_action/" + id2;
                    const future = common.ajax("DELETE", url2, {});
                    futures.push(future);

                    future.catch(json => {
                        if (json.status === UNAUTHORIZED) {
                            UIkit.modal.alert("<h2>Failed to delete action</h2>You are not logged in");
                        } else {
                            UIkit.modal.alert("<h2>Failed to delete action</h2>" + common.get_error(json));
                        }
                    });
                }
            }
            deletedActionIDs = [];

            // Handle images

            [].forEach.call(document.querySelectorAll(".product-image"), (element: HTMLElement) => {
                const id2 = element.getAttribute("data-id");

                if (id2 == "new") {
                    const url2 = apiBasePath + "/webshop/product_image";
                    // Note: data URLs are formatted like: data:[<mediatype>][;base64],<data>
                    // This will extract the Base64 data
                    const imageData = element.getElementsByTagName("img")[0].src.split(",")[1];
                    const future = common.ajax("POST", url2, {
                        product_id: window.productId,
                        image: imageData, // This will be some Base64 encoded image data for new images
                        image_name: element.getAttribute("data-name"), // This is something that includes the file extension, will be used to save the file to reasonable path
                    });
                    futures.push(future);

                    future.then(json => {
                        // Update the form with the image id
                        element.setAttribute("data-id", json.data.id);
                    }).catch (json => {
                        if (json.status === UNAUTHORIZED) {
                            UIkit.modal.alert("<h2>Failed to save image</h2>You are not logged in");
                        } else {
                            UIkit.modal.alert("<h2>Failed to save image</h2>" + common.get_error(json));
                        }
                    });
                }
            });


            for (const id2 of deletedImageIDs) {
                if (id2 !== "new") {
                    const url2 = apiBasePath + "/webshop/product_image/" + id2;
                    const future = common.ajax("DELETE", url2, {});
                    futures.push(future);

                    future.catch(json => {
                        if (json.status === UNAUTHORIZED) {
                            UIkit.modal.alert("<h2>Failed to delete image</h2>You are not logged in");
                        } else {
                            UIkit.modal.alert("<h2>Failed to delete image</h2>" + common.get_error(json));
                        }
                    });
                }
            }
            deletedImageIDs = [];

            Promise.all(futures).then(() => {
                // Redirect the user back to the webshop
                window.location.href = "/shop#edit";
            }).catch(() => {
                isSaving = false;
                // UIkit.modal.alert("Saved");
                spinner.classList.remove("progress-spinner-visible");
            });
        }).catch(json => {
            isSaving = false;
            spinner.classList.remove("progress-spinner-visible");
            if (json.status === UNAUTHORIZED) {
                UIkit.modal.alert("<h2>Failed to save product</h2>You are not logged in");
            } else {
                UIkit.modal.alert("<h2>Failed to save product</h2>" + common.get_error(json));
            }
        });
    });

    document.getElementById("add-action").addEventListener("click", ev => {
        ev.preventDefault();
        new UIkit.modal('#add-action-modal').hide();

        addAction({
            id: "new",
            action_id: common.getValue("#add-action-category"),
            value: 0,
        });
    });
});