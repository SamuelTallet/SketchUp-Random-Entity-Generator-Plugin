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

	switch (document.querySelector('#reg-preset').value) {

		case 'flowers':

			document.querySelector('#reg-entity-count').value = 500;

			document.querySelector('#reg-entity-min-rotation').value = 0.0;
			document.querySelector('#reg-entity-max-rotation').value = 359.0;

			document.querySelector('#reg-entity-min-size').value = 0.7;
			document.querySelector('#reg-entity-max-size').value = 1.0;

			document.querySelector('#reg-push-ents-to-down').value = 0;
			document.querySelector('#reg-entity-max-altitude').value = 0;

			document.querySelector('#reg-entity-density').value = 10.0;

			document.querySelector('#reg-glue-ents-to-ground').value = 'yes';
			document.querySelector('#reg-follow-face-normals').value = 'no';

			document.querySelector('#reg-avoid-ent-collision').value = 'no';

			document.querySelector('#reg-overwite-ent-colors').value = 'no';

			break;

		case 'trees':

			document.querySelector('#reg-entity-count').value = 500;

			document.querySelector('#reg-entity-min-rotation').value = 0.0;
			document.querySelector('#reg-entity-max-rotation').value = 359.0;

			document.querySelector('#reg-entity-min-size').value = 0.7;
			document.querySelector('#reg-entity-max-size').value = 1.0;

			document.querySelector('#reg-push-ents-to-down').value = 50;
			document.querySelector('#reg-entity-max-altitude').value = 0;

			document.querySelector('#reg-entity-density').value = 1000.0;

			document.querySelector('#reg-glue-ents-to-ground').value = 'yes';
			document.querySelector('#reg-follow-face-normals').value = 'no';

			document.querySelector('#reg-avoid-ent-collision').value = 'no';

			document.querySelector('#reg-overwite-ent-colors').value = 'no';

			break;

		case 'grass_blocks':

			document.querySelector('#reg-entity-count').value = 500;

			document.querySelector('#reg-entity-min-rotation').value = 0.0;
			document.querySelector('#reg-entity-max-rotation').value = 0.0;

			document.querySelector('#reg-entity-min-size').value = 1.0;
			document.querySelector('#reg-entity-max-size').value = 1.0;

			document.querySelector('#reg-push-ents-to-down').value = 0;
			document.querySelector('#reg-entity-max-altitude').value = 0;

			document.querySelector('#reg-entity-density').value = 2.5;

			document.querySelector('#reg-glue-ents-to-ground').value = 'yes';
			document.querySelector('#reg-follow-face-normals').value = 'yes';

			document.querySelector('#reg-avoid-ent-collision').value = 'no';

			document.querySelector('#reg-overwite-ent-colors').value = 'no';

			break;

		case 'big_bang':

			document.querySelector('#reg-entity-count').value = 100;

			document.querySelector('#reg-entity-min-rotation').value = 0.0;
			document.querySelector('#reg-entity-max-rotation').value = 359.0;

			document.querySelector('#reg-entity-min-size').value = -10.0;
			document.querySelector('#reg-entity-max-size').value = 10.0;

			document.querySelector('#reg-push-ents-to-down').value = 0;
			document.querySelector('#reg-entity-max-altitude').value = 0;

			document.querySelector('#reg-entity-density').value = 100;

			document.querySelector('#reg-glue-ents-to-ground').value = 'no';
			document.querySelector('#reg-follow-face-normals').value = 'no';

			document.querySelector('#reg-avoid-ent-collision').value = 'yes';

			document.querySelector('#reg-overwite-ent-colors').value = 'no';

			break;

	}

};

/**
 * Listens to "preset change" event.
 */
REG.listenToPresetChange = () => {

	document.querySelector('#reg-preset').addEventListener('change', REG.onPresetChange);

};

/**
 * Collects parameters.
 *
 * @return {object}
 */
REG.collectParameters = () => {

	let parametersOut = {};

	let parametersIn = Array.from(document.querySelectorAll('#reg-parameters [name]'));

	parametersIn.forEach(parameterIn => {

		if ( !parameterIn.disabled ) {

			parametersOut[parameterIn.name] = parameterIn.value;

		}

	});

	return parametersOut;

};

/**
 * Listens to "validation" event.
 */
REG.listenToValidation = () => {

	document.querySelector('#reg-validate-button').addEventListener('click', _event => {

		sketchup.setParameters(REG.collectParameters());

	});

};

/**
 * Initializes everything.
 */
REG.initialize = () => {

	if ( REG.randomZoneIsDefined ) {

		document.querySelector('#reg-entity-max-altitude').disabled = true;
		document.querySelector('#reg-entity-max-altitude').title
			= document.querySelector('#reg-entity-max-altitude').dataset.disabledExplanation;

		document.querySelector('#reg-entity-density').disabled = true;
		document.querySelector('#reg-entity-density').title
			= document.querySelector('#reg-entity-density').dataset.disabledExplanation;

		document.querySelector('#reg-glue-ents-to-ground').disabled = true;
		document.querySelector('#reg-glue-ents-to-ground').title
			= document.querySelector('#reg-glue-ents-to-ground').dataset.disabledExplanation;
		
	} else {

		document.querySelector('#reg-push-ents-to-down').disabled = true;
		document.querySelector('#reg-push-ents-to-down').title
			= document.querySelector('#reg-push-ents-to-down').dataset.disabledExplanation;


		document.querySelector('#reg-follow-face-normals').disabled = true;
		document.querySelector('#reg-follow-face-normals').title
			= document.querySelector('#reg-follow-face-normals').dataset.disabledExplanation;

	}

	REG.listenToPresetChange();

	document.querySelector('#reg-preset').value = REG.preset; 
	REG.onPresetChange();

	REG.listenToValidation();

};

// When document is ready:
document.addEventListener('DOMContentLoaded', _event => {

	sketchup.getPresetAndRandomZoneStatus({

		onCompleted: REG.initialize

	});

});
