/**
 * REG Parameters.
 *
 * @package REG extension for SketchUp
 *
 * @copyright © 2019 Samuel Tallet
 *
 * @licence GNU General Public License 3.0
 */

/**
 * REG plugin namespace.
 */
REG = {};

/**
 * Get element matching a CSS selector.
 *
 * @param {string} selector
 *
 * @return {object}
 */
REG.get = selector => {

	return document.querySelector(selector);

};

/**
 * Get elements matching a CSS selector.
 *
 * @param {string} selector
 *
 * @return {object}
 */
REG.getAll = selector => {

	return Array.from(document.querySelectorAll(selector));

};

/**
 * Preset.
 *
 * @type {string}
 */
REG.preset = '';

/**
 * Is Random Zone defined?
 *
 * @type {boolean}
 */
REG.randomZoneIsDefined = false;

/**
 * Function called on "preset change" event.
 */
REG.onPresetChange = _event => {

	switch (REG.get('#reg-preset').value) {

		case 'flowers':

			REG.get('#reg-entity-count').value = 500;

			REG.get('#reg-entity-min-rotation').value = 0.0;
			REG.get('#reg-entity-max-rotation').value = 359.0;

			REG.get('#reg-entity-min-size').value = 0.7;
			REG.get('#reg-entity-max-size').value = 1.0;

			REG.get('#reg-push-ents-to-down').value = 0;
			REG.get('#reg-entity-max-altitude').value = 0;

			REG.get('#reg-entity-density').value = 10.0;

			REG.get('#reg-glue-ents-to-ground').value = 'yes';
			REG.get('#reg-follow-face-normals').value = 'no';

			REG.get('#reg-avoid-ent-collision').value = 'no';

			REG.get('#reg-overwrite-ent-colors').value = 'no';

			break;

		case 'trees':

			REG.get('#reg-entity-count').value = 500;

			REG.get('#reg-entity-min-rotation').value = 0.0;
			REG.get('#reg-entity-max-rotation').value = 359.0;

			REG.get('#reg-entity-min-size').value = 0.7;
			REG.get('#reg-entity-max-size').value = 1.0;

			REG.get('#reg-push-ents-to-down').value = 50;
			REG.get('#reg-entity-max-altitude').value = 0;

			REG.get('#reg-entity-density').value = 1000.0;

			REG.get('#reg-glue-ents-to-ground').value = 'yes';
			REG.get('#reg-follow-face-normals').value = 'no';

			REG.get('#reg-avoid-ent-collision').value = 'no';

			REG.get('#reg-overwrite-ent-colors').value = 'no';

			break;

		case 'grass_blocks':

			REG.get('#reg-entity-count').value = 500;

			REG.get('#reg-entity-min-rotation').value = 0.0;
			REG.get('#reg-entity-max-rotation').value = 0.0;

			REG.get('#reg-entity-min-size').value = 1.0;
			REG.get('#reg-entity-max-size').value = 1.0;

			REG.get('#reg-push-ents-to-down').value = 0;
			REG.get('#reg-entity-max-altitude').value = 0;

			REG.get('#reg-entity-density').value = 2.5;

			REG.get('#reg-glue-ents-to-ground').value = 'yes';
			REG.get('#reg-follow-face-normals').value = 'yes';

			REG.get('#reg-avoid-ent-collision').value = 'no';

			REG.get('#reg-overwrite-ent-colors').value = 'no';

			break;

		case 'big_bang':

			REG.get('#reg-entity-count').value = 100;

			REG.get('#reg-entity-min-rotation').value = 0.0;
			REG.get('#reg-entity-max-rotation').value = 359.0;

			REG.get('#reg-entity-min-size').value = -10.0;
			REG.get('#reg-entity-max-size').value = 10.0;

			REG.get('#reg-push-ents-to-down').value = 0;
			REG.get('#reg-entity-max-altitude').value = 0;

			REG.get('#reg-entity-density').value = 100;

			REG.get('#reg-glue-ents-to-ground').value = 'no';
			REG.get('#reg-follow-face-normals').value = 'no';

			REG.get('#reg-avoid-ent-collision').value = 'yes';

			REG.get('#reg-overwrite-ent-colors').value = 'no';

			break;

	}

};

/**
 * Listens to "preset change" event.
 */
REG.listenToPresetChange = () => {

	REG.get('#reg-preset').addEventListener('change', REG.onPresetChange);

};

/**
 * Collects parameters.
 *
 * @return {object}
 */
REG.collectParameters = () => {

	let parameters = {};

	REG.getAll('#reg-parameters [name]').forEach(parameter => {

		if ( !parameter.disabled ) {

			parameters[parameter.name] = parameter.value;

		}

	});

	return parameters;

};

/**
 * Listens to "input change" event.
 */
REG.listenToInputChange = () => {

	REG.getAll('#reg-parameters input').forEach(parameter => {

		parameter.addEventListener('change', event => {

			regExp = RegExp(event.currentTarget.dataset.regexPattern, 'g');

			if ( !regExp.test(event.currentTarget.value) ) {

				event.currentTarget.value = event.currentTarget.dataset.defaultValue;

			}

		});

	});

};

/**
 * Listens to "preview" event.
 */
REG.listenToPreview = () => {

	REG.get('#reg-preview-button').addEventListener('click', _event => {

		sketchup.setParameters(REG.collectParameters(), 'preview');

	});

};

/**
 * Listens to "validate" event.
 */
REG.listenToValidate = () => {

	REG.get('#reg-validate-button').addEventListener('click', _event => {

		sketchup.setParameters(REG.collectParameters(), 'validate');

	});

};

/**
 * Initializes everything.
 */
REG.initialize = () => {

	if ( REG.randomZoneIsDefined ) {

		REG.get('#reg-entity-max-altitude').disabled = true;
		REG.get('#reg-entity-max-altitude').title
			= REG.get('#reg-entity-max-altitude').dataset.disabledExplanation;

		REG.get('#reg-entity-density').disabled = true;
		REG.get('#reg-entity-density').title
			= REG.get('#reg-entity-density').dataset.disabledExplanation;

		REG.get('#reg-glue-ents-to-ground').disabled = true;
		REG.get('#reg-glue-ents-to-ground').title
			= REG.get('#reg-glue-ents-to-ground').dataset.disabledExplanation;
		
	} else {

		REG.get('#reg-push-ents-to-down').disabled = true;
		REG.get('#reg-push-ents-to-down').title
			= REG.get('#reg-push-ents-to-down').dataset.disabledExplanation;


		REG.get('#reg-follow-face-normals').disabled = true;
		REG.get('#reg-follow-face-normals').title
			= REG.get('#reg-follow-face-normals').dataset.disabledExplanation;

	}

	REG.listenToPresetChange();

	REG.get('#reg-preset').value = REG.preset; 
	REG.onPresetChange();

	REG.listenToInputChange();

	REG.listenToPreview();
	REG.listenToValidate();

};

// When document is ready:
document.addEventListener('DOMContentLoaded', _event => {

	sketchup.getPresetAndRandomZoneStatus({

		onCompleted: REG.initialize

	});

});
